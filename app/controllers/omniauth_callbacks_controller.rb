# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    unless user
      redirect_to new_session_path,
                  alert: "Sign in requires a verified @u.northwestern.edu or @northwestern.edu Google account."
      return
    end

    return_to = session.delete(:return_to)

    reset_session
    session[:user_id] = user.id
    redirect_to return_to.presence || root_path, notice: "Signed in successfully."
  end

  def failure
    redirect_to new_session_path, alert: "Google sign-in did not complete. Please try again."
  end
end
