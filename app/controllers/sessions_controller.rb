# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_login, only: :destroy
  before_action :ensure_development!, only: :dev_sign_in

  DEV_SIGN_IN_ACCOUNTS = [
    { email: "admin@u.northwestern.edu", first_name: "Admin" },
    { email: "student@u.northwestern.edu", first_name: "Sam" }
  ].freeze

  def new
    if params[:return_to].present?
      path = ApplicationController.normalize_post_form_return_path(params[:return_to])
      session[:return_to] = path if path.present?
    end
    @return_to = session[:return_to].presence
    @dev_sign_in_users = dev_sign_in_users if Rails.env.development?
  end

  def dev_sign_in
    user = dev_sign_in_users.find { |u| u.id == params[:user_id].to_i }
    unless user
      redirect_to new_session_path, alert: "Unknown dev account."
      return
    end

    return_to = session[:return_to]
    reset_session
    session[:return_to] = return_to
    session[:user_id] = user.id
    redirect_to return_to.presence || root_path,
                notice: "Signed in locally as #{user.first_name} (#{user.email})."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully."
  end

  private

  def ensure_development!
    head :not_found unless Rails.env.development?
  end

  def dev_sign_in_users
    User.ensure_seed_accounts!
    DEV_SIGN_IN_ACCOUNTS.filter_map do |attrs|
      User.find_or_create_by!(email: attrs[:email]) do |user|
        user.first_name = attrs[:first_name]
        user.provider = "google_oauth2"
        user.uid = "dev-local-#{Digest::SHA256.hexdigest(attrs[:email])[0, 32]}"
      end
    end
  end
end
