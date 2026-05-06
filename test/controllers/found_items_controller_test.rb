require "test_helper"

class FoundItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @found_item = found_items(:one)
  end

  test "should get index" do
    get found_items_url
    assert_response :success
  end

  test "should redirect new when not signed in" do
    get new_found_item_url
    assert_redirected_to new_session_url
  end

  test "should get new when signed in" do
    sign_in_as(users(:nu_student))
    get new_found_item_url
    assert_response :success
  end

  test "should redirect create when not signed in" do
    assert_no_difference("FoundItem.count") do
      post found_items_url, params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: @found_item.description, image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: "Unauthorized" } }
    end
    assert_redirected_to new_session_url
  end

  test "should create found_item when signed in" do
    sign_in_as(users(:nu_student))
    assert_difference("FoundItem.count") do
      post found_items_url, params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: @found_item.description, image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    end

    assert_redirected_to found_item_url(FoundItem.last)
  end

  test "should show found_item" do
    get found_item_url(@found_item)
    assert_response :success
  end

  test "should redirect edit when not signed in" do
    get edit_found_item_url(@found_item)
    assert_redirected_to new_session_url
  end

  test "should redirect edit when signed in but not admin" do
    sign_in_as(users(:nu_student))
    get edit_found_item_url(@found_item)
    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
  end

  test "should get edit when admin" do
    sign_in_as(users(:admin))
    get edit_found_item_url(@found_item)
    assert_response :success
  end

  test "should redirect update when not admin" do
    sign_in_as(users(:nu_student))
    patch found_item_url(@found_item), params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: @found_item.description, image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    assert_redirected_to root_url
  end

  test "should update found_item when admin" do
    sign_in_as(users(:admin))
    patch found_item_url(@found_item), params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: "Admin update.", image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    assert_redirected_to found_item_url(@found_item)
    assert_equal "Admin update.", @found_item.reload.description
  end

  test "should redirect destroy when not admin" do
    sign_in_as(users(:nu_student))
    assert_no_difference("FoundItem.count") do
      delete found_item_url(@found_item)
    end
    assert_redirected_to root_url
  end

  test "should destroy found_item when admin" do
    sign_in_as(users(:admin))
    item = FoundItem.create!(
      title: "Delete me",
      description: "Temporary row for destroy test.",
      category: "Book",
      location_found: "Campus",
      date_found: Date.current,
      contact_name: "Admin",
      contact_email: "admin@u.northwestern.edu",
      status: "unclaimed"
    )
    assert_difference("FoundItem.count", -1) do
      delete found_item_url(item)
    end

    assert_redirected_to found_items_url
  end

  test "should redirect claim when not signed in" do
    post claim_found_item_url(@found_item)
    assert_redirected_to new_session_url
  end

  test "should claim found_item when signed in" do
    sign_in_as(users(:nu_student))
    assert_equal "unclaimed", @found_item.status

    post claim_found_item_url(@found_item)

    assert_redirected_to found_item_url(@found_item)
    @found_item.reload
    assert_equal "claimed", @found_item.status
    assert_equal users(:nu_student).id, @found_item.claimed_by_user_id
  end

  test "should not claim already claimed item" do
    item = found_items(:two)
    sign_in_as(users(:nu_student))

    post claim_found_item_url(item)

    assert_redirected_to found_item_url(item)
    assert_match(/not available/i, flash[:alert].to_s)
  end
end
