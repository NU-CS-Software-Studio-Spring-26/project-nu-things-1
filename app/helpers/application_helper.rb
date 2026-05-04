module ApplicationHelper
  # Prefer stored first name (from sign-up / sign-in); otherwise derive from email local part.
  def display_user_name(user)
    return "" if user.blank?

    fn = user.try(:first_name).to_s.strip
    return fn if fn.present?

    local = user.email.to_s.split("@", 2).first
    return "there" if local.blank?

    local.tr("._", " ").titleize
  end

  # Guest → sign in with return_to. Signed in → new listing form. Uses request.session so it never depends on controller helper_method resolution.
  def post_listing_url(new_path)
    path = ApplicationController.strip_return_path(new_path).presence
    path ||= new_path.to_s.strip.split("?", 2).first.presence
    return new_session_path if path.blank?

    uid = request.session[:user_id]
    if uid.present? && User.exists?(id: uid)
      path
    else
      new_session_path(return_to: path)
    end
  end

  def link_to_new_listing(label, new_path, **html_options)
    opts = html_options.deep_dup
    opts[:data] = (opts[:data] || {}).merge(turbo_prefetch: false, turbo: false)
    link_to label, post_listing_url(new_path), **opts
  end

  def listing_image_tag(record, alt: nil, **html_options)
    alt_text = alt.presence || record.try(:title).presence || "Listing photo"
    if record.photo.attached?
      image_tag record.photo, alt: alt_text, **html_options
    elsif record.try(:image_url).present?
      image_tag record.image_url, alt: alt_text, **html_options
    end
  end

  def lost_status_badge_class(status)
    case status
    when "open" then "text-bg-warning"
    when "resolved" then "text-bg-success"
    else "text-bg-secondary"
    end
  end

  def found_status_badge_class(status)
    case status
    when "unclaimed" then "text-bg-info"
    when "claimed" then "text-bg-secondary"
    else "text-bg-secondary"
    end
  end
end
