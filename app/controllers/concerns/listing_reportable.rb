# frozen_string_literal: true

module ListingReportable
  extend ActiveSupport::Concern

  private

  def process_listing_report(listing, mailer_method:, audit_action:)
    details = params[:report_details].to_s.strip
    if details.length < 20
      redirect_to listing, alert: "Please describe what’s wrong and why you’re reporting this post (at least 20 characters)."
      return
    end

    return if redirect_if_profanity!(listing, details)

    name, email = reporter_identity_for_report
    if name.blank? || email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to listing, alert: "Please include your name and email so moderators can follow up if needed."
      return
    end

    ContactMailer.public_send(mailer_method, listing, name, email, details).deliver_later
    record_audit(audit_action, auditable: listing, metadata: { reporter_email: email })
    redirect_to listing, notice: "Thanks—your report was sent to the moderators."
  end
end
