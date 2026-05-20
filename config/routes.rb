Rails.application.routes.draw do
  root "home#index"

  get "about", to: "pages#about", as: :about
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms

  match "/auth/failure", to: "omniauth_callbacks#failure", via: %i[get post]
  get "/auth/:provider/callback", to: "omniauth_callbacks#create"

  resource :session, only: %i[new destroy]

  resources :users, only: %i[show]

  resources :lost_items do
    member do
      post :report
    end
  end
  resources :found_items do
    member do
      post :claim
      post :report
    end
  end
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
