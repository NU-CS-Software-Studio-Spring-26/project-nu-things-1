# frozen_string_literal: true

require "test_helper"

class MarketplaceTransactionTest < ActiveSupport::TestCase
  test "roles_for for sale listing assign buyer and seller" do
    conversation = conversations(:admin_to_student_marketplace)
    listing = marketplace_listings(:for_sale_one)

    buyer, seller = MarketplaceTransaction.roles_for(conversation, listing)

    assert_equal users(:admin), buyer
    assert_equal users(:nu_student), seller
  end

  test "complete when both sides marked" do
    transaction = MarketplaceTransaction.create!(
      conversation: conversations(:admin_to_student_marketplace),
      marketplace_listing: marketplace_listings(:for_sale_one),
      buyer: users(:admin),
      seller: users(:nu_student),
      buyer_marked_complete_at: Time.current
    )

    assert_not transaction.complete?

    transaction.update!(seller_marked_complete_at: Time.current)
    assert transaction.complete?
  end
end
