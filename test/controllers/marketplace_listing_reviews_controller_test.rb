require "test_helper"

class MarketplaceListingReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = marketplace_listings(:for_sale_one)
  end

  test "create requires sign in" do
    post marketplace_listing_marketplace_listing_reviews_url(@listing),
         params: { marketplace_listing_review: { rating: 5, body: "Great!" } }
    assert_redirected_to new_session_path
  end

  test "poster cannot review own listing" do
    sign_in_as users(:nu_student)
    post marketplace_listing_marketplace_listing_reviews_url(@listing),
         params: { marketplace_listing_review: { rating: 5, body: "Great!" } }
    assert_redirected_to marketplace_listing_url(@listing)
    assert_match(/can't review your own listing/i, flash[:alert])
  end

  test "signed in user can create review" do
    sign_in_as users(:admin)
    assert_difference("MarketplaceListingReview.count", 1) do
      post marketplace_listing_marketplace_listing_reviews_url(@listing),
           params: { marketplace_listing_review: { rating: 5, body: "Easy deal." } }
    end
    assert_redirected_to marketplace_listing_url(@listing)
    review = MarketplaceListingReview.order(:id).last
    assert_equal users(:admin), review.user
    assert_equal "Easy deal.", review.body
  end

  test "user cannot submit duplicate review" do
    sign_in_as users(:admin)
    post marketplace_listing_marketplace_listing_reviews_url(@listing),
         params: { marketplace_listing_review: { rating: 4 } }
    assert_redirected_to marketplace_listing_url(@listing)

    post marketplace_listing_marketplace_listing_reviews_url(@listing),
         params: { marketplace_listing_review: { rating: 3 } }
    assert_redirected_to marketplace_listing_url(@listing)
    assert_match(/already been taken/i, flash[:alert])
  end
end
