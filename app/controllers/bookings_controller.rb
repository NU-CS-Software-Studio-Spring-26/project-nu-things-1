class BookingsController < ApplicationController
  before_action :require_login
  before_action :set_rental_item
  before_action :set_booking, only: %i[cancel confirm mark_given mark_received mark_returned mark_return_received rate_exchange]

  rate_limit to: 20, within: 1.hour, only: :create, scope: :rental_booking_requests,
             by: -> { request.remote_ip }, with: :notify_rate_limit
  rate_limit to: 10, within: 1.hour, only: :rate_exchange, scope: :rental_exchange_ratings,
             by: -> { "booking_exchange_ratings/user/#{current_user.id}" }, with: :notify_rate_limit

  def create
    unless @rental_item.visible_to?(current_user)
      redirect_to rental_items_path, alert: "You can't request bookings from this owner."
      return
    end

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
      notice = if @booking.exchange_complete?
        "Marked as received. Handoff is complete on both sides."
      else
        "Marked as received. Waiting for the owner to confirm they gave you the item."
      end
      redirect_to @rental_item, notice: notice
    else
      redirect_to @rental_item, alert: "Could not update booking."
    end
  end

  def mark_returned
    unless @booking.can_mark_returned?(current_user)
      redirect_to @rental_item, alert: "You can't mark this booking as returned."
      return
    end

    if @booking.update(renter_marked_returned_at: Time.current)
      notice = if @booking.return_complete?
        "Marked as returned. Return is complete on both sides."
      else
        "Marked as returned. Waiting for the owner to confirm they received it back."
      end
      redirect_to @rental_item, notice: notice
    else
      redirect_to @rental_item, alert: "Could not update booking."
    end
  end

  def mark_return_received
    unless @booking.can_mark_return_received?(current_user)
      redirect_to @rental_item, alert: "You can't mark this booking as received back."
      return
    end

    if @booking.update(owner_marked_return_received_at: Time.current)
      notice = if @booking.return_complete?
        "Marked as received back. Return is complete on both sides."
      else
        "Marked as received back. Waiting for the renter to confirm they returned it."
      end
      redirect_to @rental_item, notice: notice
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

  def rate_exchange
    interaction_phase = params[:phase].to_s
    unless BookingExchangeRating::INTERACTION_PHASES.include?(interaction_phase)
      redirect_to @rental_item, alert: "Invalid interaction phase."
      return
    end

    ratee = @booking.exchange_ratee_for(current_user)
    unless ratee
      redirect_to @rental_item, alert: "You can't rate this exchange."
      return
    end

    phase_complete = interaction_phase == "pickup" ? @booking.pickup_complete? : @booking.return_complete?
    unless phase_complete
      redirect_to @rental_item, alert: "You can only rate after both sides complete this interaction."
      return
    end

    if @booking.exchange_rating_from_to(current_user, ratee, interaction_phase: interaction_phase).present?
      redirect_to @rental_item, notice: "You've already rated this user for this exchange."
      return
    end

    rating = @booking.exchange_ratings.build(exchange_rating_params)
    rating.rater = current_user
    rating.ratee = ratee
    rating.interaction_phase = interaction_phase

    if rating.save
      redirect_to @rental_item, notice: "Thanks for rating your exchange partner!"
    else
      redirect_to @rental_item, alert: rating.errors.full_messages.join(", ")
    end
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

  def exchange_rating_params
    params.expect(exchange_rating: [ :rating, :reason, :body ])
  end
end
