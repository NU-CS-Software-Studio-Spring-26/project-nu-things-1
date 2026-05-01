# Test-only helper to establish session[:user_id] in integration tests.
class TestSessionsController < ApplicationController
  skip_forgery_protection

  def create
    return head :not_found unless Rails.env.test?

    user = User.find(params.expect(:user_id))
    session[:user_id] = user.id
    redirect_to root_path
  end
end
