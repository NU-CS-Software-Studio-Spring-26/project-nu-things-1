require "test_helper"

class RentalReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rental = rental_items(:two)
  end

  test "create requires sign in" do
    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: 5, body: "Great!" } }
    assert_redirected_to new_session_path
  end

  test "poster cannot review own listing" do
    rental = rental_items(:one)
    sign_in_as users(:nu_student)
    rental.conversations.create!(starter: users(:admin), subject: "Question", last_message_at: Time.current)

    post rental_item_rental_reviews_url(rental),
         params: { rental_review: { rating: 5, body: "Great!" } }
    assert_redirected_to rental_item_url(rental)
    assert_match(/can't review your own listing/i, flash[:alert])
  end

  test "user must message listing before reviewing" do
    sign_in_as users(:admin)
    Conversation.where(listable: @rental, starter: users(:admin)).delete_all

    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: 5, body: "Great!" } }
    assert_redirected_to rental_item_url(@rental)
    assert_match(/send a message/i, flash[:alert])
  end

  test "signed in user can create review after messaging" do
    sign_in_as users(:admin)
    assert_difference("RentalReview.count", 1) do
      post rental_item_rental_reviews_url(@rental),
           params: { rental_review: { rating: 5, body: "Smooth rental." } }
    end
    assert_redirected_to rental_item_url(@rental)
    review = RentalReview.order(:id).last
    assert_equal users(:admin), review.user
    assert_equal "Smooth rental.", review.body
  end

  test "user cannot submit duplicate review" do
    sign_in_as users(:admin)
    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: 4 } }
    assert_redirected_to rental_item_url(@rental)

    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: 3 } }
    assert_redirected_to rental_item_url(@rental)
    assert_match(/already left a review/i, flash[:alert])
  end

  test "cannot review unavailable rental" do
    sign_in_as users(:admin)
    @rental.update!(status: "rented")

    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: 5, body: "Great!" } }
    assert_redirected_to rental_item_url(@rental)
    assert_match(/available rentals/i, flash[:alert])
  end

  test "invalid review re-renders show with form values" do
    sign_in_as users(:admin)
    post rental_item_rental_reviews_url(@rental),
         params: { rental_review: { rating: "", body: "Missing stars" } }
    assert_response :unprocessable_entity
    assert_select "textarea[name='rental_review[body]']", text: "Missing stars"
  end
end
