Rails.application.routes.draw do
  root "home#index"

  resources :lost_items
  resources :found_items

  get "up" => "rails/health#show", as: :rails_health_check
end
