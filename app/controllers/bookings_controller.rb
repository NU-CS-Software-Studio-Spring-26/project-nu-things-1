class BookingsController < ApplicationController
  before_action :require_login
  before_action :set_rental_item
  before_action :set_booking, only: %i[cancel confirm mark_given mark_received]

  rate_limit to: 20, within: 1.hour, only: :create, scope: :rental_booking_requests,
             by: -> { request.remote_ip }, with: :notify_rate_limit

  def create
    @booking = @rental_item.bookings.build(booking_params)
    @booking.user = current_user
    @booking.status = "pending"

    if @booking.save
      BookingMailer.confirmation_email(@booking).deliver_later
      redirect_to @rental_item, notice: "Booking request sent. The owner can accept it below."
    else
      redirect_to @rental_item, alert: @booking.errors.full_messages.join(", ")
    end
  end

  def confirm
    unless @booking.can_confirm?(current_user)
      redirect_to @rental_item, alert: "You can't accept this booking."
      return
    end

    if @booking.update(status: "confirmed")
      redirect_to @rental_item, notice: "Booking accepted. Use the handoff buttons when you exchange the item."
    else
      redirect_to @rental_item, alert: @booking.errors.full_messages.join(", ")
    end
  end

  def mark_given
    unless @booking.can_mark_given?(current_user)
      redirect_to @rental_item, alert: "You can't mark this booking as given."
      return
    end

    if @booking.update(owner_marked_given_at: Time.current)
      redirect_to @rental_item, notice: "Marked as given. Waiting for the renter to confirm they received the item."
    else
      redirect_to @rental_item, alert: "Could not update booking."
    end
  end

  def mark_received
    unless @booking.can_mark_received?(current_user)
      redirect_to @rental_item, alert: "You can't mark this booking as received."
      return
    end

    if @booking.update(renter_marked_received_at: Time.current)
      msg = if @booking.exchange_complete?
              "Marked as received. Handoff is complete on both sides."
            else
              "Marked as received. Waiting for the owner to confirm they gave you the item."
            end
      redirect_to @rental_item, notice: msg
    else
      redirect_to @rental_item, alert: "Could not update booking."
    end
  end

  def cancel
    unless @booking.can_cancel?(current_user)
      redirect_to @rental_item, alert: "You can't cancel this booking."
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
    @rental_item = RentalItem.find(params[:rental_item_id])
  end

  def set_booking
    @booking = @rental_item.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :notes)
  end
end
