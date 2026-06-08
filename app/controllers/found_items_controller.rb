class FoundItemsController < ApplicationController
  before_action :set_found_item, only: %i[show edit update destroy claim report]
  before_action -> { require_owner_or_admin(@found_item) }, only: %i[edit update]
  before_action :require_admin, only: %i[destroy]

  rate_limit to: 25, within: 24.hours, only: :report, scope: :found_item_reports_found_items,
             by: :report_rate_limit_key, with: :notify_rate_limit

  def index
    @found_items = FoundItem.with_attached_photo.visible_to(current_user).order(date_found: :desc, created_at: :desc)
    @categories = listing_filter_categories
    @found_items = filter_where_in(@found_items, :category, params[:category], @categories)
    @found_items = filter_by_search(@found_items, params[:q])
    @pagy, @found_items, @grouped_found_items = prepare_listings_index(@found_items)
  end

  def show
  end

  def new
    @found_item = FoundItem.new
    apply_saved_identity_to_new_listing(@found_item)
  end

  def edit
  end

  def create
    @found_item = FoundItem.new(found_item_params)
    @found_item.user = current_user
    apply_saved_identity_to_new_listing(@found_item)

    if @found_item.save
      redirect_to @found_item, notice: "Found item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def claim
    if @found_item.status != "unclaimed"
      redirect_to @found_item, alert: "This item is not available to claim."
      return
    end

    @found_item.update!(status: "claimed", claimed_by_user_id: current_user.id)
    record_audit("found_item.claim", auditable: @found_item)
    redirect_to @found_item, notice: "You marked this item as claimed."
  end

  def update
    if @found_item.update(found_item_params)
      redirect_to @found_item, notice: "Found item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    record_audit("found_item.destroy", auditable: @found_item, metadata: { found_item_id: @found_item.id })
    @found_item.destroy
    redirect_to found_items_path, notice: "Found item was successfully removed.", status: :see_other
  end

  def report
    details = params[:report_details].to_s.strip
    if details.length < 20
      redirect_to @found_item, alert: "Please describe what’s wrong and why you’re reporting this post (at least 20 characters)."
      return
    end

    if Moderate::Text.bad_words?(details)
      redirect_to @found_item, alert: profanity_blocked_alert
      return
    end

    name, email = reporter_identity_for_report
    if name.blank? || email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to @found_item, alert: "Please include your name and email so moderators can follow up if needed."
      return
    end

    ContactMailer.found_item_report(@found_item, name, email, details).deliver_later
    record_audit("found_item.report", auditable: @found_item, metadata: { reporter_email: email })
    redirect_to @found_item, notice: "Thanks—your report was sent to the moderators."
  end

  private

  def set_found_item
    @found_item = FoundItem.with_attached_photo.find(params.expect(:id))
    ensure_listing_visible!(@found_item)
  end

  def found_item_params
    attrs = [ :title, :description, :category, :custom_category, :location_found, :date_found,
              :contact_name, :contact_email, :image_url, :photo, :storage_location, :color, :brand ]
    attrs << :status if action_name == "create"
    params.expect(found_item: attrs)
  end
end
