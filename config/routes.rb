Rails.application.routes.draw do
  root "home#index"

  get "about", to: "pages#about", as: :about
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms

  match "/auth/failure", to: "omniauth_callbacks#failure", via: %i[get post]
  get "/auth/:provider/callback", to: "omniauth_callbacks#create"

  resource :session, only: %i[new destroy] do
    post :dev_sign_in, on: :collection if Rails.env.development?
  end

  resources :users, only: %i[show]

  resources :conversations, only: %i[index show] do
    resources :messages, only: %i[create], controller: "conversation_messages"
  end

  post "lost_items/:lost_item_id/conversation", to: "listing_conversations#create", as: :lost_item_conversation
  post "found_items/:found_item_id/conversation", to: "listing_conversations#create", as: :found_item_conversation
  post "rental_items/:rental_item_id/conversation", to: "listing_conversations#create", as: :rental_item_conversation
  post "marketplace_listings/:marketplace_listing_id/conversation",
       to: "listing_conversations#create", as: :marketplace_listing_conversation

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
    resources :rental_reviews, only: [ :create ]
    resources :bookings, only: [ :create ] do
      member do
        patch :cancel
        patch :confirm
        patch :mark_given
        patch :mark_received
        patch :mark_returned
        patch :mark_return_received
        post :rate_exchange
      end
      collection do
        get :calendar_data
      end
    end
  end
  resources :marketplace_listings do
    resources :marketplace_listing_reviews, only: [ :create ]
  end

  post "contacts/create_lost_item_contact", to: "contacts#create_lost_item_contact", as: :create_lost_item_contact
  post "contacts/create_found_item_contact", to: "contacts#create_found_item_contact", as: :create_found_item_contact
  post "contacts/create_rental_item_contact", to: "contacts#create_rental_item_contact", as: :create_rental_item_contact
  post "contacts/create_marketplace_listing_contact", to: "contacts#create_marketplace_listing_contact", as: :create_marketplace_listing_contact

  get "up" => "rails/health#show", as: :rails_health_check
end
