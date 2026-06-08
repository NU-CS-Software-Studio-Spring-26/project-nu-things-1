class ApplicationController < ActionController::Base
  include AssistantSession
  include AuditableLogging
  include Pagy::Method
  include ProfanityGuard

  LISTINGS_PER_PAGE = 12

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Runs before other callbacks so listing "new/create" (and found-item claim) cannot post without a session,
  # even if a controller callback list is changed accidentally.
  prepend_before_action :enforce_listing_authentication

  # Paths we accept for ?return_to= on the sign-in page (open-redirect safe).
  POST_FORM_RETURN_PATHS = %w[
    /lost_items/new
    /found_items/new
    /rental_items/new
    /marketplace_listings/new
  ].freeze

  helper_method :current_user, :signed_in?, :admin?, :can_edit_post?, :unread_conversations_count,
                :can_message_listing?, :can_request_booking?, :blocked_by_poster?,
                :conversation_messaging_blocked?

  def unread_conversations_count
    return 0 unless signed_in?

    Conversation.for_user(current_user).includes(:conversation_participants).count do |conversation|
      conversation.unread_for?(current_user)
    end
  end

  # Strip query string and (for absolute URLs) take only the path segment.
  def self.strip_return_path(raw)
    str = raw.is_a?(Array) ? raw.compact.map(&:to_s).find(&:present?) : raw&.to_s
    str = str.to_s.strip.split("?", 2).first || ""

    if str.start_with?("http://", "https://")
      URI.parse(str).path.to_s.split("?", 2).first || ""
    else
      str
    end
  rescue URI::InvalidURIError
    ""
  end

  def self.normalize_post_form_return_path(raw)
    path = strip_return_path(raw)
    return nil if path.blank?

    POST_FORM_RETURN_PATHS.include?(path) ? path : nil
  end

  private

  def admin?
    current_user&.admin?
  end

  def can_edit_post?(record)
    signed_in? && record.respond_to?(:editable_by?) && record.editable_by?(current_user)
  end

  def require_owner_or_admin(record)
    unless signed_in?
      store_return_to
      redirect_to new_session_path, alert: "Please sign in with your Northwestern account to continue."
      return
    end
    return if record.respond_to?(:editable_by?) && record.editable_by?(current_user)

    redirect_back fallback_location: root_path, alert: "You don't have permission to do that."
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

  def enforce_listing_authentication
    return unless listing_action_requires_sign_in?

    require_login
  end

  def listing_action_requires_sign_in?
    case controller_name
    when "lost_items", "rental_items", "marketplace_listings"
      action_name.in?(%w[new create])
    when "found_items"
      action_name.in?(%w[new create claim])
    else
      false
    end
  end

  # Pre-fills "your name" / email on new listing forms from the signed-in account (first name + Northwestern email).
  def apply_saved_identity_to_new_listing(record)
    return unless signed_in?
    return if record.persisted?

    u = current_user
    display = u.first_name.to_s.strip.presence || helpers.display_user_name(u).to_s.strip.presence
    return if display.blank?

    if record.respond_to?(:contact_name=) && record.contact_name.blank?
      record.contact_name = display
    end
    if record.respond_to?(:contact_email=) && record.contact_email.blank?
      record.contact_email = u.email
    end
    if record.respond_to?(:owner_name=) && record.owner_name.blank?
      record.owner_name = display
    end
    if record.respond_to?(:owner_email=) && record.owner_email.blank?
      record.owner_email = u.email
    end
  end

  def store_return_to
    session[:return_to] = request.fullpath if request.get? || request.head?
  end

  def pop_return_to
    session.delete(:return_to)
  end

  # Only apply a WHERE filter when the raw param is in +allowed+ (Strings).
  # ActiveRecord already binds placeholders for where(column: value), but
  # whitelisting avoids odd values and makes filter intent explicit.
  def filter_where_in(relation, column, raw, allowed)
    return relation if raw.blank?
    return relation unless allowed.is_a?(Array)

    value = raw.to_s
    return relation unless allowed.include?(value)

    relation.where(column => value)
  end

  def filter_category_options(model, exclude: [])
    options = (ListingCategories::VALUES + model.distinct.pluck(:category).compact).uniq.sort
    exclude.any? ? options - exclude : options
  end

  def filter_by_search(relation, query)
    term = query.to_s.strip
    return relation if term.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
    relation.where(
      "LOWER(title) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)",
      pattern, pattern
    )
  end

  def blocked_by_poster?(listable)
    return false unless signed_in?

    listable.visible_to?(current_user) == false
  end

  def can_message_listing?(listable)
    return false unless signed_in?

    poster = listable.poster_account
    poster.present? && poster != current_user && listable.visible_to?(current_user)
  end

  def can_request_booking?(rental_item)
    return false unless signed_in?
    return false if rental_item.posted_by?(current_user)

    rental_item.visible_to?(current_user) && rental_item.status == "available"
  end

  def conversation_messaging_blocked?(conversation)
    return false unless signed_in?

    other = conversation.other_participant(current_user)
    return false if other.blank?

    current_user.blocking?(other) || other.blocking?(current_user)
  end

  def ensure_listing_visible!(listing)
    return unless signed_in?
    return if listing.viewable_to?(current_user)

    raise ActiveRecord::RecordNotFound
  end

  def paginate_listings(relation)
    pagy(
      :offset,
      relation,
      limit: LISTINGS_PER_PAGE,
      anchor_string: 'data-turbo-frame="listings"'
    )
  end

  # Name + email for lost/found listing report mailers (signed-in uses account; guests use form params).
  def reporter_identity_for_report
    if signed_in?
      u = current_user
      n = u.first_name.to_s.strip.presence || helpers.display_user_name(u).to_s.strip
      [ n.presence || u.email.to_s.split("@", 2).first.to_s, u.email ]
    else
      [ params[:reporter_name].to_s.strip, params[:reporter_email].to_s.strip.downcase ]
    end
  end

  # Generic flash for non-attribute flows (contact forms, reports).
  def profanity_blocked_alert
    Rails.application.config.x.profanity_flash_alert
  end

  # Used by +rate_limit ... with: :notify_rate_limit+ (HTML UX instead of bare 429).
  def notify_rate_limit
    message = "Too many attempts in a short time. Please wait a few minutes before trying again."
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.turbo_stream do
        @assistant_error = message
        render "assistant/messages/create", status: :too_many_requests
      end
    end
  end

  # Shared keys for listing report throttles (signed-in vs guest buckets).
  def report_rate_limit_key
    if signed_in?
      "report/user/#{current_user.id}"
    else
      digest = Digest::SHA256.hexdigest([ params[:reporter_email].to_s.downcase.strip, request.remote_ip ].join(":"))[0, 48]
      "report/guest/#{digest}"
    end
  end
end
