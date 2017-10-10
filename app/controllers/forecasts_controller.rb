class ForecastsController < ApplicationController
  before_action :set_forecast, only: [:show, :edit, :update, :destroy]

  # GET /forecasts
  # GET /forecasts.json
  def index
    @forecasts = Forecast.where('created_at > ?' , Time.now - 24.hours)
    @image = ''

    if params[:search]
      case params[:search]
        when /[a-zA-Z]+/
          search_query = "q=#{params[:search]}"
        when /^-?\d+\.*\d+\,\s?-?\d+\.*\d+$/
          split = params[:search].split(',')
          lat = split[0]
          lon = split[1]
          search_query = "lat=#{lat}&lon=#{lon}"
        when /[0-9]{5}/
          search_query = "zip=#{params[:search]},us"
        when /[0-9]+/
          search_query = "id=#{params[:search]}"
      end

      puts search_query
      response = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast?#{search_query}&APPID=#{api_id}")
      puts response

      if response['cod'] == '400'
        flash[:error] = "Well this is embarrassing I can't find your town...maybe try coordinates???"
      elsif response && response['cod'] == '200'
        location = response['city']['name']
        weather = response["list"][0]["weather"][0]["description"]
        @results = "Looks like it's going to be #{weather} in #{location} today."
        @image = get_image(response["list"][0]["weather"][0]["description"])
      end
    end



  end

  def get_image(forecast)
    case forecast
      when /clear/ || /sun/
        return "clear.svg"
      when /lightning/ || /thunder/
        return "thunder.svg"
      when /part/ || /broken/
        return "partly.svg"
      when /cloud/
        return "cloud.svg"
      when /rain/ || /sleet/
        return "rain.svg"
      else
        return "vane.svg"
    end

  end

  # GET /forecasts/1
  # GET /forecasts/1.json
  def show

  end

  # GET /forecasts/new
  def new
    @forecast = Forecast.new
  end

  # GET /forecasts/1/edit
  def edit
  end

  # POST /forecasts
  # POST /forecasts.json
  def create
    @forecast = Forecast.new(forecast_params)

    respond_to do |format|
      if @forecast.save
        format.html { redirect_to @forecast, notice: 'Forecast was successfully created.' }
        format.json { render :show, status: :created, location: @forecast }
      else
        format.html { render :new }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /forecasts/1
  # PATCH/PUT /forecasts/1.json
  def update
    respond_to do |format|
      if @forecast.update(forecast_params)
        format.html { redirect_to @forecast, notice: 'Forecast was successfully updated.' }
        format.json { render :show, status: :ok, location: @forecast }
      else
        format.html { render :edit }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forecasts/1
  # DELETE /forecasts/1.json
  def destroy
    @forecast.destroy
    respond_to do |format|
      format.html { redirect_to forecasts_url, notice: 'Forecast was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_forecast
      @forecast = Forecast.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def forecast_params
      params.fetch(:forecast, {})
    end

    def api_id
      ENV['OPEN_WEATHER_API_KEY']
    end
end
