Rails.application.routes.draw do
  root "home#index"

  resources :lost_items
  resources :found_items
  
  post "contacts/create_lost_item_contact", to: "contacts#create_lost_item_contact", as: :create_lost_item_contact
  post "contacts/create_found_item_contact", to: "contacts#create_found_item_contact", as: :create_found_item_contact

  get "up" => "rails/health#show", as: :rails_health_check
end
