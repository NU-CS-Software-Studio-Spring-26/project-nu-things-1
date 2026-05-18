# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_rental_item
  before_action :set_booking

  def new
    redirect_unless_reviewable!
    return if performed?

    @review = Review.new(rating: 5)
  end

  def create
    redirect_unless_reviewable!
    return if performed?

    @review = Review.new(review_params.merge(
      reviewer: current_user,
      reviewee: @booking.rental_item.user,
      subject: @booking
    ))

    if @review.save
      redirect_to rental_item_path(@rental_item), notice: "Thanks for your review."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_rental_item
    @rental_item = RentalItem.with_attached_photo.find(params.expect(:rental_item_id))
  end

  def set_booking
    @booking = @rental_item.bookings.find(params.expect(:booking_id))
  end

  def review_params
    params.expect(review: [ :rating, :body ])
  end

  def redirect_unless_reviewable!
    if @booking.renter_id != current_user.id
      redirect_to rental_item_path(@rental_item), alert: "You can only review your own bookings."
      return
    end

    unless @booking.renter_can_leave_review?
      redirect_to rental_item_path(@rental_item),
                  alert: "You can only review after the rental dates have passed, and the booking must not be cancelled."
      return
    end

    if @booking.renter_review.present?
      redirect_to rental_item_path(@rental_item), alert: "You’ve already reviewed this booking."
      return
    end

    return if @booking.rental_item.user_id.present?

    redirect_to rental_item_path(@rental_item), alert: "This listing has no owner profile to review."
  end
end
