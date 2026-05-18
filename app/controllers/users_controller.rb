# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = User.find(params.expect(:id))

    scope = ->(rel) { rel.with_attached_photo }

    @authored_lost_items = scope.call(@user.lost_items).order(date_lost: :desc, created_at: :desc)
    @authored_found_items = scope.call(@user.found_items).order(date_found: :desc, created_at: :desc)
    @authored_marketplace_listings = scope.call(@user.marketplace_listings).order(updated_at: :desc)
    @authored_rental_items = scope.call(@user.rental_items).order(created_at: :desc)

    @claimed_found_items = scope.call(FoundItem.where(claimed_by_user_id: @user.id))
      .order(date_found: :desc, updated_at: :desc)

    @received_reviews = @user.reviews_received.includes(:reviewer, :subject).order(created_at: :desc).limit(100)
    @reviews_count = @user.reviews_received.count
    @reviews_average = @user.average_received_rating
  end
end
