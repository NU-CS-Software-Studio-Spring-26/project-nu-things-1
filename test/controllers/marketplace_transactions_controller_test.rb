# frozen_string_literal: true

require "test_helper"

class MarketplaceTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conversation = conversations(:admin_to_student_marketplace)
    @transaction = MarketplaceTransaction.find_or_create_for!(@conversation)
  end

  test "buyer can mark item received" do
    sign_in_as(users(:admin))

    patch mark_buyer_complete_conversation_marketplace_transaction_path(@conversation)

    assert_redirected_to conversation_path(@conversation)
    assert @transaction.reload.buyer_marked_complete?
  end

  test "seller can mark payment received" do
    sign_in_as(users(:nu_student))

    patch mark_seller_complete_conversation_marketplace_transaction_path(@conversation)

    assert_redirected_to conversation_path(@conversation)
    assert @transaction.reload.seller_marked_complete?
  end

  test "buyer can rate seller after both sides complete" do
    @transaction.update!(buyer_marked_complete_at: Time.current, seller_marked_complete_at: Time.current)
    sign_in_as(users(:admin))

    assert_difference -> { MarketplaceExchangeRating.count }, 1 do
      post rate_exchange_conversation_marketplace_transaction_path(@conversation),
           params: { exchange_rating: { rating: 5, reasons: [ "communication" ] } }
    end

    assert_redirected_to conversation_path(@conversation)
    assert_in_delta 5.0, users(:nu_student).reload.reputation_score, 0.001
    assert_equal 2, users(:nu_student).reputation_ratings_count
  end

  test "cannot rate before both sides complete" do
    @transaction.update!(buyer_marked_complete_at: Time.current)
    sign_in_as(users(:admin))

    assert_no_difference -> { MarketplaceExchangeRating.count } do
      post rate_exchange_conversation_marketplace_transaction_path(@conversation),
           params: { exchange_rating: { rating: 5, reasons: [ "timeliness" ] } }
    end

    assert_redirected_to conversation_path(@conversation)
  end

  test "marketplace transaction panel appears on marketplace conversation" do
    sign_in_as(users(:admin))
    get conversation_path(@conversation)

    assert_response :success
    assert_select "h2", text: /Complete purchase/i
    assert_select "button", text: /I received the item/i
  end
end
