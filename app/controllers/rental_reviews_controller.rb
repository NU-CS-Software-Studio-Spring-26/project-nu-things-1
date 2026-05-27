class RentalReviewsController < ApplicationController
  before_action :require_login
  before_action :set_rental_item

  rate_limit to: 10, within: 1.hour, only: :create, scope: :rental_reviews,
             by: -> { "rental_reviews/user/#{current_user.id}" }, with: :notify_rate_limit

  def create
    if @rental_item.posted_by?(current_user)
      redirect_to @rental_item, alert: "You can't review your own listing."
      return
    end

    if @rental_item.status != "available"
      redirect_to @rental_item, alert: "Reviews can only be added to available rentals."
      return
    end

    unless @rental_item.conversations.exists?(starter_id: current_user.id)
      redirect_to @rental_item, alert: "Send a message about this listing before leaving a review."
      return
    end

    if @rental_item.rental_reviews.exists?(user_id: current_user.id)
      redirect_to @rental_item, alert: "You already left a review for this listing."
      return
    end

    @review = @rental_item.rental_reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @rental_item, notice: "Thanks for your review!"
    else
      prepare_rental_show_assignments
      render template: "rental_items/show", status: :unprocessable_entity
    end
  end

  private

  def set_rental_item
    @rental_item = RentalItem.with_attached_photo
      .includes(:rental_reviews, :bookings)
      .find(params.expect(:rental_item_id))
  end

  def prepare_rental_show_assignments
    @user_review = @rental_item.rental_reviews.find_by(user: current_user)
    @can_leave_review = @rental_item.can_leave_review?(current_user)
  end

  def review_params
    params.expect(rental_review: [ :rating, :body ])
  end
end
