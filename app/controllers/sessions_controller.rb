class SessionsController < ApplicationController
  before_action :require_login, only: :destroy

  def new
  end

  def create
    email = User.normalize_email(params[:email])
    user = email.present? ? User.find_by(email: email) : nil

    if user&.authenticate(params[:password])
      return_to = session.delete(:return_to)
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
end
