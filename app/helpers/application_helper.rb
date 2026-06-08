module ApplicationHelper
  def brand_name
    ::PurplePost::BRAND_NAME
  end

  def brand_color
    ::PurplePost::BRAND_COLOR
  end

  def page_title(page_name = nil)
    if page_name.present?
      "#{page_name} — #{brand_name}"
    else
      brand_name
    end
  end

  def app_source_code_url
    Rails.application.config.x.source_code_url.to_s
  end

  def app_source_code_url?
    app_source_code_url.present?
  end

  # For privacy / deletion requests: PRIVACY_CONTACT_EMAIL, then ADMIN_EMAIL.
  def privacy_contact_email
    Rails.application.config.x.privacy_contact_email.presence ||
      ::PurplePost.admin_email.presence ||
      ENV["PRIVACY_CONTACT_EMAIL"].to_s.strip.downcase.presence
  end

  # Prefer stored first name (from sign-up / sign-in); otherwise derive from email local part.
  def display_user_name(user)
    return "" if user.blank?

    fn = user.try(:first_name).to_s.strip
    return fn if fn.present?

    local = user.email.to_s.split("@", 2).first
    return "there" if local.blank?

    local.tr("._", " ").titleize
  end

  # Default "your name" for listing and contact forms when signed in (saved first name, else email-based display).
  def prefilled_listing_contact_display
    u = current_user
    return unless u

    u.first_name.to_s.strip.presence || display_user_name(u)
  end

  def prefilled_listing_email
    current_user&.email
  end

  def prefilled_sender_name_field
    params[:sender_name].presence || prefilled_listing_contact_display
  end

  def prefilled_sender_email_field
    params[:sender_email].presence || prefilled_listing_email
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
    when "open" then "nu-badge-lost-open"
    when "resolved" then "nu-badge-lost-resolved"
    else "nu-badge-lost-default"
    end
  end

  def found_status_badge_class(status)
    case status
    when "unclaimed" then "nu-badge-found-unclaimed"
    when "claimed" then "nu-badge-found-claimed"
    else "nu-badge-found-default"
    end
  end

  # e.g. "$35.00/week" — uses stored rental_period (per_day / per_week / per_month).
  def format_rental_rate(record)
    return "" unless record.respond_to?(:rental_price) && record.rental_price.present?

    period = record.rental_period.to_s.sub(/\Aper_/, "")
    "$#{number_with_precision(record.rental_price, precision: 2)}/#{period}"
  end

  def rental_rating_summary(item)
    if item.reviews_count.positive?
      "#{number_with_precision(item.average_rating, precision: 1)} / 5"
    else
      "No ratings"
    end
  end

  def rental_reviews_summary(item)
    item.reviews_count.positive? ? pluralize(item.reviews_count, "review") : "No reviews"
  end

  def rental_past_users_summary(item)
    count = item.past_renters_count
    pluralize(count, "person", "people") + " used this item in the past"
  end

  def rental_rating_stars(item, max: 5)
    listing_rating_stars(item, max: max)
  end

  def listing_rating_stars(item, max: 5)
    if item.reviews_count.positive?
      filled = item.average_rating.round.clamp(0, max)
      ("★" * filled) + ("☆" * (max - filled))
    else
      "☆" * max
    end
  end

  def marketplace_rating_summary(item)
    if item.reviews_count.positive?
      "#{number_with_precision(item.average_rating, precision: 1)} / 5"
    else
      "No ratings"
    end
  end

  def marketplace_reviews_summary(item)
    item.reviews_count.positive? ? pluralize(item.reviews_count, "review") : "No reviews"
  end

  def marketplace_rating_stars(item, max: 5)
    listing_rating_stars(item, max: max)
  end

  def marketplace_review_rating_stars(rating, max: 5)
    filled = rating.to_i.clamp(0, max)
    ("★" * filled) + ("☆" * (max - filled))
  end

  def user_reputation_summary(user)
    count = user.reputation_ratings_count
    return "No exchange ratings yet" if count.zero?

    "#{number_with_precision(user.reputation_score, precision: 1)} / 5 (#{pluralize(count, 'rating')})"
  end

  def user_reputation_stars(user, max: 5)
    count = user.reputation_ratings_count
    return "☆" * max if count.zero?

    filled = user.reputation_score.to_f.round.clamp(0, max)
    ("★" * filled) + ("☆" * (max - filled))
  end

  def user_exchange_rating_summary(user)
    user_reputation_summary(user)
  end

  def user_exchange_rating_stars(user, max: 5)
    user_reputation_stars(user, max: max)
  end

  def show_user_reputation_breakdown?(user)
    return false if user.blank?
    return false if user.reputation_ratings_count.zero?

    !signed_in? || user != current_user
  end

  def format_reputation_average(value)
    return "—" if value.nil?

    number_with_precision(value, precision: 1)
  end

  def exchange_rating_reason_options
    ExchangeRatingReasons::REASONS.map { |value, label| [ label, value ] }
  end

  def exchange_rating_reason_summary(rating)
    rating.reason_summary
  end

  def rental_exchange_phase_label(phase)
    case phase.to_s
    when "pickup" then "Initial handoff"
    when "return" then "Return handoff"
    else phase.to_s.titleize
    end
  end

  def marketplace_category_slug(category)
    category.to_s.parameterize.presence || "other"
  end

  # Powdery per-category pill (uses canonical `category`, not custom label, so "Other" still styles as Other).
  def marketplace_category_badge_class(category)
    "nu-mp-cat nu-mp-cat--#{marketplace_category_slug(category)}"
  end

  def marketplace_listing_type_badge_class(listing_type)
    listing_type.to_s == "wanted" ? "nu-mp-type-wanted" : "nu-mp-type-for-sale"
  end

  def listing_index_filters_active?
    params[:q].present? || params[:category].present? || params[:listing_type].present?
  end

  def listing_index_total_count(pagy, grouped_items)
    pagy&.count || grouped_items&.values&.sum(&:size) || 0
  end

  def listing_search_results_label(count)
    term = params[:q].to_s.strip
    return if term.blank?

    "#{pluralize(count, 'result')} found for '#{h(term)}'".html_safe
  end

  def audit_log_action_label(action)
    {
      "lost_item.destroy" => "Deleted lost item",
      "lost_item.resolve" => "Resolved lost item",
      "lost_item.report" => "Reported lost item",
      "found_item.destroy" => "Deleted found item",
      "found_item.claim" => "Claimed found item",
      "found_item.report" => "Reported found item",
      "rental_item.destroy" => "Deleted rental item",
      "marketplace_listing.destroy" => "Deleted marketplace listing"
    }.fetch(action.to_s, action.to_s.humanize)
  end
end
