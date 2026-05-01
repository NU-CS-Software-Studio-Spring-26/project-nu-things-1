class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  def require_login
    return if signed_in?

    store_return_to
    redirect_to new_session_path, alert: "Please sign in to continue."
  end

  def store_return_to
    session[:return_to] = request.fullpath
  end

  def pop_return_to
    session.delete(:return_to)
  end
end
