require "test_helper"

class RentalItemsControllerTest < ActionDispatch::IntegrationTest
  VALID_RENTAL_PARAMS = {
    title: "Camping tent",
    description: "Two-person tent for weekend trips.",
    category: "Camping Gear",
    rental_price: 18,
    rental_period: "per_day",
    condition: "Good",
    location: "Evanston near campus",
    available_from: Date.new(2026, 6, 1),
    available_to: Date.new(2026, 9, 1),
    owner_name: "Test Owner",
    owner_email: "owner@u.northwestern.edu",
    deposit_required: 20,
    status: "available"
  }.freeze

  test "should get index" do
    get rental_items_url
    assert_response :success
  end

  test "should redirect new when not signed in" do
    get new_rental_item_url
    assert_redirected_to new_session_url
  end

  test "should get new when signed in" do
    sign_in_as(users(:nu_student))
    get new_rental_item_url
    assert_response :success
  end

  test "should redirect create when not signed in" do
    assert_no_difference("RentalItem.count") do
      post rental_items_url, params: { rental_item: VALID_RENTAL_PARAMS }
    end
    assert_redirected_to new_session_url
  end

  test "should create rental_item when signed in" do
    sign_in_as(users(:nu_student))
    assert_difference("RentalItem.count") do
      post rental_items_url, params: {
        rental_item: VALID_RENTAL_PARAMS.merge(title: "Signed-in rental #{SecureRandom.hex(4)}")
      }
    end
    assert_redirected_to rental_item_url(RentalItem.last)
    assert_equal users(:nu_student).id, RentalItem.last.user_id
  end

  test "should redirect edit when not owner of legacy rental" do
    item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "Legacy rental #{SecureRandom.hex(4)}", user_id: nil)
    )
    sign_in_as(users(:nu_student))
    get edit_rental_item_url(item)
    assert_redirected_to root_url
  end

  test "should get edit when signed in as owner" do
    sign_in_as(users(:nu_student))
    item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "Owned rental #{SecureRandom.hex(4)}", user: users(:nu_student))
    )
    get edit_rental_item_url(item)
    assert_response :success
  end

  test "should redirect destroy when not admin" do
    sign_in_as(users(:nu_student))
    item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "No delete #{SecureRandom.hex(4)}", user: users(:nu_student))
    )
    assert_no_difference("RentalItem.count") do
      delete rental_item_url(item)
    end
    assert_redirected_to root_url
  end

  test "should destroy rental_item when admin" do
    sign_in_as(users(:admin))
    item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "Admin delete #{SecureRandom.hex(4)}", user: users(:nu_student))
    )
    assert_difference("RentalItem.count", -1) do
      delete rental_item_url(item)
    end
    assert_redirected_to rental_items_url
  end
end
