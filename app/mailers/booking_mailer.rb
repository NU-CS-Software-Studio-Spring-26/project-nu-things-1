class BookingMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "noreply@northwestern-lost-found.com")

  def confirmation_email(booking)
    @booking = booking
    @rental_item = booking.rental_item

    mail(
      to: @rental_item.owner_email,
      subject: "New booking request for #{@rental_item.title}"
    )
  end
end
