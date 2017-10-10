Rails.application.routes.draw do
  root to: 'forecasts#index'

  resources :forecasts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
