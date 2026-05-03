class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?, :admin?

  private

  def admin?
    current_user&.admin?
  end

  def require_admin
    unless signed_in?
      store_return_to
      redirect_to new_session_path, alert: "Please sign in with your Northwestern account to continue."
      return
    end
    return if current_user.admin?

    redirect_back fallback_location: root_path, alert: "You don't have permission to do that."
  end

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
    redirect_to new_session_path, alert: "Please sign in with your Northwestern account to continue."
  end

  def store_return_to
    session[:return_to] = request.fullpath if request.get? || request.head?
  end

  def pop_return_to
    session.delete(:return_to)
  end
end
