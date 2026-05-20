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
    message = request.env["omniauth.error.type"] || params[:message]
    alert = if message.to_s.include?("InvalidAuthenticityToken")
      "Sign-in expired or was opened in an unsafe way. Return to the sign-in page and try again."
    else
      "Google sign-in did not complete. Please try again."
    end
    redirect_to new_session_path, alert: alert
  end
end
