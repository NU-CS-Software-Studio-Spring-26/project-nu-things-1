class MarketplaceListingReviewsController < ApplicationController
  before_action :require_login
  before_action :set_marketplace_listing

  rate_limit to: 10, within: 1.hour, only: :create, scope: :marketplace_listing_reviews,
             by: -> { "marketplace_listing_reviews/user/#{current_user.id}" }, with: :notify_rate_limit

  def create
    if @marketplace_listing.posted_by?(current_user)
      redirect_to @marketplace_listing, alert: "You can't review your own listing."
      return
    end

    if @marketplace_listing.status != "active"
      redirect_to @marketplace_listing, alert: "Reviews can only be added to active listings."
      return
    end

    unless @marketplace_listing.conversations.exists?(starter_id: current_user.id)
      redirect_to @marketplace_listing, alert: "Send a message about this listing before leaving a review."
      return
    end

    if @marketplace_listing.marketplace_listing_reviews.exists?(user_id: current_user.id)
      redirect_to @marketplace_listing, alert: "You already left a review for this listing."
      return
    end

    @review = @marketplace_listing.marketplace_listing_reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @marketplace_listing, notice: "Thanks for your review!"
    else
      prepare_listing_show_assignments
      render template: "marketplace_listings/show", status: :unprocessable_entity
    end
  end

  private

  def set_marketplace_listing
    @marketplace_listing = MarketplaceListing.with_attached_photo
      .includes(:marketplace_listing_reviews)
      .find(params.expect(:marketplace_listing_id))
  end

  def prepare_listing_show_assignments
    @user_review = @marketplace_listing.marketplace_listing_reviews.find_by(user: current_user)
    @can_leave_review = @marketplace_listing.can_leave_review?(current_user)
  end

  def review_params
    params.expect(marketplace_listing_review: [ :rating, :body ])
  end
end
