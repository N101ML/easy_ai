Rails.application.routes.draw do
  resources :trainings
  resources :loras
  resources :renders
  resources :images
  resources :models do
    resources :fine_tunes, only: [:index, :new, :create]
  end

  resources :fine_tunes, only: [:show, :edit, :update, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
  root "renders#index"
end
