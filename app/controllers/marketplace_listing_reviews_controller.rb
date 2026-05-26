class MarketplaceListingReviewsController < ApplicationController
  before_action :require_login
  before_action :set_marketplace_listing

  rate_limit to: 10, within: 1.hour, only: :create, scope: :marketplace_listing_reviews,
             by: -> { "marketplace_listing_reviews/user/#{current_user.id}" }, with: :notify_rate_limit

  def create
    if @marketplace_listing.poster_account == current_user
      redirect_to @marketplace_listing, alert: "You can't review your own listing."
      return
    end

    @review = @marketplace_listing.marketplace_listing_reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @marketplace_listing, notice: "Thanks for your review!"
    else
      redirect_to @marketplace_listing, alert: @review.errors.full_messages.join(", ")
    end
  end

  private

  def set_marketplace_listing
    @marketplace_listing = MarketplaceListing.find(params.expect(:marketplace_listing_id))
  end

  def review_params
    params.expect(marketplace_listing_review: [ :rating, :body ])
  end
end
