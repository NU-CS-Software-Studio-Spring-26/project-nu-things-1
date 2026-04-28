Rails.application.routes.draw do
  root "home#index"

  resources :lost_items, except: %i[edit update destroy]
  get "lost_items/owner/:token/edit" => "lost_items#edit_owner", as: :edit_lost_item_owner
  patch "lost_items/owner/:token" => "lost_items#update_owner", as: :update_lost_item_owner
  delete "lost_items/owner/:token" => "lost_items#destroy_owner", as: :destroy_lost_item_owner
  post "lost_items/:id/claim" => "claims#create_for_lost_item", as: :claim_lost_item

  resources :found_items, except: %i[edit update destroy]
  get "found_items/owner/:token/edit" => "found_items#edit_owner", as: :edit_found_item_owner
  patch "found_items/owner/:token" => "found_items#update_owner", as: :update_found_item_owner
  delete "found_items/owner/:token" => "found_items#destroy_owner", as: :destroy_found_item_owner
  post "found_items/:id/claim" => "claims#create_for_found_item", as: :claim_found_item

  resource :session, only: %i[new create destroy]
  get "session/:token" => "sessions#consume", as: :consume_session

  get "up" => "rails/health#show", as: :rails_health_check
end
