Rails.application.routes.draw do
  resources :loras
  resources :models
  resources :renders, only: [:index, :new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
  root "models#index"
end
