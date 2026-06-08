class MarketplaceListingsController < ApplicationController
  include ListingReportable

  before_action :set_marketplace_listing, only: %i[show edit update destroy report]
  before_action -> { require_owner_or_admin(@marketplace_listing) }, only: %i[edit update]
  before_action :require_admin, only: %i[destroy]

  rate_limit to: 25, within: 24.hours, only: :report, scope: :marketplace_listing_reports_marketplace_listings,
             by: :report_rate_limit_key, with: :notify_rate_limit

  def index
    @marketplace_listings = MarketplaceListing.with_attached_photo
      .includes(:marketplace_listing_reviews, :user)
      .visible_to(current_user)
      .where(status: "active")
      .order(created_at: :desc)
    @marketplace_listings = filter_where_in(
      @marketplace_listings,
      :listing_type,
      params[:listing_type],
      MarketplaceListing::LISTING_TYPES
    )
    @categories = listing_filter_categories
    @marketplace_listings = filter_where_in(@marketplace_listings, :category, params[:category], @categories)
    @marketplace_listings = filter_by_search(@marketplace_listings, params[:q])
    @pagy, @marketplace_listings, @grouped_marketplace_listings = prepare_listings_index(@marketplace_listings)
  end

  def show
  end

  def new
    @marketplace_listing = MarketplaceListing.new
    apply_saved_identity_to_new_listing(@marketplace_listing)
  end

  def edit
  end

  def create
    @marketplace_listing = MarketplaceListing.new(marketplace_listing_params)
    @marketplace_listing.user = current_user
    apply_saved_identity_to_new_listing(@marketplace_listing)

    if @marketplace_listing.save
      redirect_to @marketplace_listing, notice: "Listing was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @marketplace_listing.update(marketplace_listing_params)
      redirect_to @marketplace_listing, notice: "Listing was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    record_audit("marketplace_listing.destroy", auditable: @marketplace_listing,
      metadata: { marketplace_listing_id: @marketplace_listing.id })
    @marketplace_listing.destroy
    redirect_to marketplace_listings_path, notice: "Listing was successfully removed.", status: :see_other
  end

  def report
    process_listing_report(@marketplace_listing, mailer_method: :marketplace_listing_report,
      audit_action: "marketplace_listing.report")
  end

  private

  def set_marketplace_listing
    @marketplace_listing = MarketplaceListing.with_attached_photo
      .includes(:marketplace_listing_reviews)
      .find(params.expect(:id))
    ensure_listing_visible!(@marketplace_listing)
    if signed_in?
      @user_review = @marketplace_listing.marketplace_listing_reviews.find_by(user: current_user)
      @can_leave_review = @marketplace_listing.can_leave_review?(current_user)
    end
    @review ||= MarketplaceListingReview.new
  end

  def marketplace_listing_params
    params.expect(marketplace_listing: [
      :title,
      :description,
      :category,
      :condition,
      :image_url,
      :photo,
      :location,
      :listing_type,
      :price,
      :contact_name,
      :contact_email,
      :contact_phone,
      :custom_category,
      :status
    ])
  end
end
