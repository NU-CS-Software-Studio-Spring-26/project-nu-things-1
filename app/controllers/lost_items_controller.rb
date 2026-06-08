class LostItemsController < ApplicationController
  include ListingReportable

  before_action :set_lost_item, only: %i[show edit update destroy resolve report]
  before_action -> { require_owner_or_admin(@lost_item) }, only: %i[edit update resolve]
  before_action :require_admin, only: %i[destroy]

  rate_limit to: 25, within: 24.hours, only: :report, scope: :lost_item_reports_lost_items,
             by: :report_rate_limit_key, with: :notify_rate_limit

  def index
    @lost_items = LostItem.with_attached_photo.visible_to(current_user).order(date_lost: :desc, created_at: :desc)
    @categories = listing_filter_categories
    @lost_items = filter_by_listing_category(@lost_items, params[:category], @categories)
    @lost_items = filter_by_search(@lost_items, params[:q])
    @pagy, @lost_items, @grouped_lost_items = prepare_listings_index(@lost_items)
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
    @lost_item = LostItem.new(lost_item_params)
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
    record_audit("lost_item.destroy", auditable: @lost_item, metadata: { lost_item_id: @lost_item.id })
    @lost_item.destroy
    redirect_to lost_items_path, notice: "Lost item was successfully removed.", status: :see_other
  end

  def resolve
    if @lost_item.status != "open"
      redirect_to @lost_item, alert: "This listing is already resolved."
      return
    end

    @lost_item.update!(status: "resolved")
    record_audit("lost_item.resolve", auditable: @lost_item)
    redirect_to @lost_item, notice: "Marked as resolved. Thanks for updating your post!"
  end

  def report
    process_listing_report(@lost_item, mailer_method: :lost_item_report, audit_action: "lost_item.report")
  end

  private

  def set_lost_item
    @lost_item = LostItem.with_attached_photo.find(params.expect(:id))
    ensure_listing_visible!(@lost_item)
  end

  def lost_item_params
    params.expect(lost_item: [ :title, :description, :category, :custom_category, :location_lost, :date_lost,
                               :contact_name, :contact_email, :status, :image_url, :photo, :reward, :color, :brand ])
  end
end
