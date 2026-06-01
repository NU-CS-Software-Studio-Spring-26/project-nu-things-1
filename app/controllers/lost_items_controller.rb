class LostItemsController < ApplicationController
  before_action :set_lost_item, only: %i[show edit update destroy resolve report]
  before_action -> { require_owner_or_admin(@lost_item) }, only: %i[edit update resolve]
  before_action :require_admin, only: %i[destroy]

  rate_limit to: 25, within: 24.hours, only: :report, scope: :lost_item_reports_lost_items,
             by: :report_rate_limit_key, with: :notify_rate_limit

  def index
    @lost_items = LostItem.with_attached_photo.order(date_lost: :desc, created_at: :desc)
    @categories = filter_category_options(LostItem, exclude: ListingCategories::LOST_FOUND_FILTER_EXCLUDED)
    @lost_items = filter_where_in(@lost_items, :category, params[:category], @categories)
    @lost_items = filter_by_search(@lost_items, params[:q])
  end

  def show
  end

  def new
    @lost_item = LostItem.new
    apply_saved_identity_to_new_listing(@lost_item)
  end

  def edit
  end

  def create
    @lost_item = LostItem.new(lost_item_create_params)
    @lost_item.status = "open"
    @lost_item.user = current_user
    apply_saved_identity_to_new_listing(@lost_item)

    if @lost_item.save
      redirect_to @lost_item, notice: "Lost item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lost_item.update(lost_item_params)
      redirect_to @lost_item, notice: "Lost item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lost_item.destroy
    redirect_to lost_items_path, notice: "Lost item was successfully removed.", status: :see_other
  end

  def resolve
    if @lost_item.status != "open"
      redirect_to @lost_item, alert: "This listing is already resolved."
      return
    end

    @lost_item.update!(status: "resolved")
    redirect_to @lost_item, notice: "Marked as resolved. Thanks for updating your post!"
  end

  def report
    details = params[:report_details].to_s.strip
    if details.length < 20
      redirect_to @lost_item, alert: "Please describe what’s wrong and why you’re reporting this post (at least 20 characters)."
      return
    end

    if Moderate::Text.bad_words?(details)
      redirect_to @lost_item, alert: profanity_blocked_alert
      return
    end

    name, email = reporter_identity_for_report
    if name.blank? || email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to @lost_item, alert: "Please include your name and email so moderators can follow up if needed."
      return
    end

    ContactMailer.lost_item_report(@lost_item, name, email, details).deliver_later
    redirect_to @lost_item, notice: "Thanks—your report was sent to the moderators."
  end

  private

  def set_lost_item
    @lost_item = LostItem.with_attached_photo.find(params.expect(:id))
  end

  def lost_item_params
    params.expect(lost_item: [ :title, :description, :category, :custom_category, :location_lost, :date_lost,
                               :contact_name, :contact_email, :status, :image_url, :photo, :reward, :color, :brand ])
  end

  def lost_item_create_params
    params.expect(lost_item: [ :title, :description, :category, :custom_category, :location_lost, :date_lost,
                              :contact_name, :contact_email, :image_url, :photo, :reward, :color, :brand ])
  end
end
