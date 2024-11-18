Rails.application.routes.draw do
  resources :fine_tunes
  resources :trainings
  resources :loras
  resources :models
  resources :renders
  resources :images

  get "up" => "rails/health#show", as: :rails_health_check
  root "renders#index"
end
