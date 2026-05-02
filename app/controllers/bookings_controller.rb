class BookingsController < ApplicationController
  before_action :set_rental_item
  before_action :set_booking, only: [ :show, :cancel ]

  def create
    @booking = @rental_item.bookings.build(booking_params)

    if @booking.save
      BookingMailer.confirmation_email(@booking).deliver_later
      redirect_to @rental_item, notice: "Booking request created successfully!"
    else
      redirect_to @rental_item, alert: @booking.errors.full_messages.join(", ")
    end
  end

  def cancel
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
        backgroundColor: "#4b2e83",
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
