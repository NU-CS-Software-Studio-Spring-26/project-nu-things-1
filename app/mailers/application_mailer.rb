class ApplicationMailer < ActionMailer::Base
  default from: lambda {
    ENV["RESEND_FROM"].presence ||
      Rails.application.credentials.dig(:resend, :from).presence ||
      "onboarding@resend.dev"
  }
  layout "mailer"
end
