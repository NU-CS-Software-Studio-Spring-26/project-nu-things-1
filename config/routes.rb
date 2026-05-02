Rails.application.routes.draw do
  root "home#index"

  resources :lost_items
  resources :found_items
  resources :rental_items do
    resources :bookings, only: [ :create ] do
      member do
        patch :cancel
      end
      collection do
        get :calendar_data
      end
    end
  end
  resources :marketplace_listings

  post "contacts/create_lost_item_contact", to: "contacts#create_lost_item_contact", as: :create_lost_item_contact
  post "contacts/create_found_item_contact", to: "contacts#create_found_item_contact", as: :create_found_item_contact
  post "contacts/create_rental_item_contact", to: "contacts#create_rental_item_contact", as: :create_rental_item_contact
  post "contacts/create_marketplace_listing_contact", to: "contacts#create_marketplace_listing_contact", as: :create_marketplace_listing_contact

  get "up" => "rails/health#show", as: :rails_health_check
end
