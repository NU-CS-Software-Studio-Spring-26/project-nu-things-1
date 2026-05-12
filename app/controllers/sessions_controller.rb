class SessionsController < ApplicationController
  before_action :require_login, only: :destroy

  rate_limit to: 25, within: 15.minutes, only: :create, scope: :session_create_attempts,
             by: -> { request.remote_ip }, with: :notify_rate_limit

  def new
    if params[:return_to].present?
      path = ApplicationController.normalize_post_form_return_path(params[:return_to])
      session[:return_to] = path if path.present?
    end
    @return_to = session[:return_to].presence
  end

  def create
    User.ensure_seed_accounts! if Rails.env.development? && !User.exists?

    email = User.normalize_email(params[:email])
    user = email.present? ? User.find_by(email: email) : nil

    if user&.authenticate(params[:password])
      apply_first_name_from_sign_in(user, params[:first_name])
      return_to = session.delete(:return_to)
      if params[:return_to].present?
        return_to ||= ApplicationController.normalize_post_form_return_path(params[:return_to])
      end
      reset_session
      session[:user_id] = user.id
      redirect_to return_to.presence || root_path, notice: "Signed in successfully."
    else
      redirect_to new_session_path, alert: "Invalid email or password."
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully."
  end

  private

  def apply_first_name_from_sign_in(user, raw)
    fn = raw.to_s.strip[0, 80]
    return if fn.blank?

    user.update_column(:first_name, fn)
  end
end
