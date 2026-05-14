# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_login, only: :destroy

  def new
    if params[:return_to].present?
      path = ApplicationController.normalize_post_form_return_path(params[:return_to])
      session[:return_to] = path if path.present?
    end
    @return_to = session[:return_to].presence
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully."
  end
end
