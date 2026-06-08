class RentalItemsController < ApplicationController
  include ListingReportable

  before_action :set_rental_item, only: %i[show edit update destroy report]
  before_action -> { require_owner_or_admin(@rental_item) }, only: %i[edit update]
  before_action :require_admin, only: %i[destroy]

  rate_limit to: 25, within: 24.hours, only: :report, scope: :rental_item_reports_rental_items,
             by: :report_rate_limit_key, with: :notify_rate_limit

  def index
    @rental_items = RentalItem.with_attached_photo
      .includes(:rental_reviews, :user)
      .visible_to(current_user)
      .where(status: "available")
      .order(created_at: :desc)
    @categories = filter_category_options(RentalItem)
    @rental_items = filter_where_in(@rental_items, :category, params[:category], @categories)
    @rental_items = filter_by_search(@rental_items, params[:q])
    @pagy, @rental_items = paginate_listings(@rental_items)
  end

  def show
    @bookings = @rental_item.bookings.active.includes(:user, :exchange_ratings).order(start_date: :asc)
    if signed_in?
      @is_rental_owner = @rental_item.user_id.present? && @rental_item.user_id == current_user.id
      @renter_bookings = @bookings.select { |b| b.user_id == current_user.id }
      @owner_manage_bookings = @is_rental_owner ? @bookings : []
    end
  end

  def new
    @rental_item = RentalItem.new
    apply_saved_identity_to_new_listing(@rental_item)
  end

  def edit
  end

  def create
    @rental_item = RentalItem.new(rental_item_params)
    @rental_item.user = current_user
    apply_saved_identity_to_new_listing(@rental_item)

    if @rental_item.save
      redirect_to @rental_item, notice: "Rental item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rental_item.update(rental_item_params)
      redirect_to @rental_item, notice: "Rental item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    record_audit("rental_item.destroy", auditable: @rental_item, metadata: { rental_item_id: @rental_item.id })
    @rental_item.destroy
    redirect_to rental_items_path, notice: "Rental item was successfully removed.", status: :see_other
  end

  def report
    process_listing_report(@rental_item, mailer_method: :rental_item_report, audit_action: "rental_item.report")
  end

  private

  def set_rental_item
    @rental_item = RentalItem.with_attached_photo.includes(:rental_reviews, :bookings).find(params.expect(:id))
    ensure_listing_visible!(@rental_item)
    if signed_in?
      @user_review = @rental_item.rental_reviews.find_by(user: current_user)
      @can_leave_review = @rental_item.can_leave_review?(current_user)
    end
    @review ||= RentalReview.new
  end

  def rental_item_params
    params.expect(rental_item: [ :title, :description, :category, :rental_price, :rental_period,
                                  :condition, :location, :available_from, :available_to, :image_url, :photo,
                                  :owner_name, :owner_email, :owner_phone, :deposit_required, :status ])
  end
end
