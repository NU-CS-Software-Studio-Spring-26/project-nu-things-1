# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :set_rental_item
  before_action :require_login, only: %i[create cancel]
  before_action :set_booking, only: %i[show cancel]

  rate_limit to: 20, within: 1.hour, only: :create, scope: :rental_booking_requests,
             by: -> { request.remote_ip }, with: :notify_rate_limit

  def show
    redirect_to @rental_item
  end

  def create
    @booking = @rental_item.bookings.build(booking_attributes)
    @booking.renter = current_user

    if @booking.save
      BookingMailer.confirmation_email(@booking).deliver_later
      redirect_to @rental_item, notice: "Booking request created successfully!"
    else
      redirect_to @rental_item, alert: @booking.errors.full_messages.join(", ")
    end
  end

  def cancel
    unless @booking.renter_id == current_user.id || can_edit_post?(@booking.rental_item) || admin?
      redirect_to @rental_item, alert: "You can’t cancel this booking."
      return
    end

    if @booking.update(status: "cancelled")
      redirect_to @rental_item, notice: "Booking cancelled."
    else
      redirect_to @rental_item, alert: "Could not cancel booking."
    end
  end

  def calendar_data
    bookings = @rental_item.bookings.active
    events = bookings.map do |booking|
      {
        start: booking.start_date.iso8601,
        end: booking.end_date.iso8601,
        title: "Booked",
        backgroundColor: "#4e2a84",
        borderColor: "#3a2466",
        display: "background"
      }
    end

    render json: events
  end

  private

  def set_rental_item
    @rental_item = RentalItem.find(params.expect(:rental_item_id))
  end

  def set_booking
    @booking = @rental_item.bookings.find(params.expect(:id))
  end

  def booking_attributes
    raw = params[:booking].present? ? params.fetch(:booking, {}) : params
    raw.permit(:start_date, :end_date, :notes)
  end
end
