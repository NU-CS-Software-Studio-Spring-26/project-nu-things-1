# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = User.find(params.expect(:id))
    if signed_in? && current_user != @user && @user.blocking?(current_user)
      raise ActiveRecord::RecordNotFound
    end

    scope = ->(rel) { rel.with_attached_photo }

    @authored_lost_items = scope.call(@user.lost_items).order(date_lost: :desc, created_at: :desc)
    @authored_found_items = scope.call(@user.found_items).order(date_found: :desc, created_at: :desc)
    @authored_marketplace_listings = scope.call(@user.marketplace_listings).order(updated_at: :desc)
    @authored_rental_items = scope.call(@user.rental_items).order(created_at: :desc)

    @requested_rental_bookings = @user.bookings
      .where.not(status: "cancelled")
      .includes(rental_item: { photo_attachment: :blob })
      .order(start_date: :desc, created_at: :desc)

    @claimed_found_items = scope.call(FoundItem.where(claimed_by_user_id: @user.id))
      .order(date_found: :desc, updated_at: :desc)

    @received_rental_exchange_ratings = @user.received_exchange_ratings
      .includes(booking: :rental_item)
      .order(created_at: :desc)
    @received_marketplace_exchange_ratings = @user.received_marketplace_exchange_ratings
      .includes(marketplace_transaction: :marketplace_listing)
      .order(created_at: :desc)
    @received_reputation_entries = (
      @received_rental_exchange_ratings.map { |rating| [ rating.created_at, :rental, rating ] } +
      @received_marketplace_exchange_ratings.map { |rating| [ rating.created_at, :marketplace, rating ] }
    ).sort_by(&:first).reverse

    return unless signed_in? && current_user == @user

    @blocked_users = current_user.blocked_users.order(:first_name, :email)
  end
end
