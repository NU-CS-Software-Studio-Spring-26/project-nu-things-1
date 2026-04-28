class SessionsController < ApplicationController
  before_action :require_login, only: :destroy

  def new
  end

  def create
    email = normalize_email(params[:email])

    # Enumeration-safe: always respond the same way.
    if allowed_login_email?(email)
      user = User.find_or_create_by!(email: email)
      token = user.login_tokens.create!(expires_at: 15.minutes.from_now)
      LoginMailer.magic_link(token).deliver_later
    end

    redirect_to root_path, notice: "If that email is eligible, we sent you a sign-in link."
  end

  def consume
    login_token = LoginToken.find_signed!(params[:token], purpose: :magic_login)

    if login_token.used? || login_token.expired?
      redirect_to new_session_path, alert: "That sign-in link is no longer valid. Please request a new one."
      return
    end

    login_token.update!(used_at: Time.current)
    session[:user_id] = login_token.user_id

    redirect_to pop_return_to || root_path, notice: "Signed in successfully."
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_session_path, alert: "That sign-in link is no longer valid. Please request a new one."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully."
  end

  private

  def normalize_email(value)
    value.to_s.strip.downcase
  end

  def allowed_login_email?(email)
    email.ends_with?("@northwestern.edu")
  end
end

