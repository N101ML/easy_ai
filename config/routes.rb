Rails.application.routes.draw do
  resources :loras
  resources :models
  resources :renders
  resources :images

  get "up" => "rails/health#show", as: :rails_health_check
  root "models#index"
end
