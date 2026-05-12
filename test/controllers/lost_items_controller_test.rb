require "test_helper"

class LostItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lost_item = lost_items(:one)
  end

  test "should get index" do
    get lost_items_url
    assert_response :success
  end

  test "should redirect new when not signed in" do
    get new_lost_item_url
    assert_redirected_to new_session_url
  end

  test "should get new when signed in" do
    sign_in_as(users(:nu_student))
    get new_lost_item_url
    assert_response :success
  end

  test "should redirect create when not signed in" do
    assert_no_difference("LostItem.count") do
      post lost_items_url, params: { lost_item: { brand: @lost_item.brand, category: @lost_item.category, color: @lost_item.color, contact_email: @lost_item.contact_email, contact_name: @lost_item.contact_name, date_lost: @lost_item.date_lost, description: @lost_item.description, image_url: @lost_item.image_url, location_lost: @lost_item.location_lost, reward: @lost_item.reward, status: @lost_item.status, title: "Unauthorized create" } }
    end
    assert_redirected_to new_session_url
  end

  test "should create lost_item when signed in" do
    sign_in_as(users(:nu_student))
    assert_difference("LostItem.count") do
      post lost_items_url, params: { lost_item: { brand: @lost_item.brand, category: @lost_item.category, color: @lost_item.color, contact_email: @lost_item.contact_email, contact_name: @lost_item.contact_name, date_lost: @lost_item.date_lost, description: @lost_item.description, image_url: @lost_item.image_url, location_lost: @lost_item.location_lost, reward: @lost_item.reward, status: @lost_item.status, title: @lost_item.title } }
    end

    assert_redirected_to lost_item_url(LostItem.last)
    assert_equal users(:nu_student).id, LostItem.last.user_id
  end

  test "should show lost_item" do
    get lost_item_url(@lost_item)
    assert_response :success
  end

  test "should redirect edit when not signed in" do
    get edit_lost_item_url(@lost_item)
    assert_redirected_to new_session_url
  end

  test "should redirect edit when signed in but not owner of legacy post" do
    sign_in_as(users(:nu_student))
    get edit_lost_item_url(lost_items(:two))
    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
  end

  test "should get edit when signed in as owner" do
    sign_in_as(users(:nu_student))
    get edit_lost_item_url(@lost_item)
    assert_response :success
  end

  test "should get edit when admin" do
    sign_in_as(users(:admin))
    get edit_lost_item_url(lost_items(:two))
    assert_response :success
  end

  test "should redirect update when not owner on legacy post" do
    sign_in_as(users(:nu_student))
    patch lost_item_url(lost_items(:two)), params: { lost_item: { brand: @lost_item.brand, category: @lost_item.category, color: @lost_item.color, contact_email: @lost_item.contact_email, contact_name: @lost_item.contact_name, date_lost: @lost_item.date_lost, description: @lost_item.description, image_url: @lost_item.image_url, location_lost: @lost_item.location_lost, reward: @lost_item.reward, status: @lost_item.status, title: @lost_item.title } }
    assert_redirected_to root_url
  end

  test "should update own lost_item when signed in" do
    sign_in_as(users(:nu_student))
    patch lost_item_url(@lost_item), params: { lost_item: { brand: @lost_item.brand, category: @lost_item.category, color: @lost_item.color, contact_email: @lost_item.contact_email, contact_name: @lost_item.contact_name, date_lost: @lost_item.date_lost, description: "Updated by owner.", image_url: @lost_item.image_url, location_lost: @lost_item.location_lost, reward: @lost_item.reward, status: @lost_item.status, title: @lost_item.title } }
    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "Updated by owner.", @lost_item.reload.description
  end

  test "should update lost_item when admin" do
    sign_in_as(users(:admin))
    legacy = lost_items(:two)
    patch lost_item_url(legacy), params: { lost_item: { brand: legacy.brand, category: legacy.category, color: legacy.color, contact_email: legacy.contact_email, contact_name: legacy.contact_name, date_lost: legacy.date_lost, description: "Updated by admin.", image_url: legacy.image_url, location_lost: legacy.location_lost, reward: legacy.reward, status: legacy.status, title: legacy.title } }
    assert_redirected_to lost_item_url(legacy)
    assert_equal "Updated by admin.", legacy.reload.description
  end

  test "should redirect destroy when not admin" do
    sign_in_as(users(:nu_student))
    assert_no_difference("LostItem.count") do
      delete lost_item_url(@lost_item)
    end
    assert_redirected_to root_url
  end

  test "should destroy lost_item when admin" do
    sign_in_as(users(:admin))
    item = LostItem.create!(
      title: "Delete me",
      description: "Temporary row for destroy test.",
      category: "Book",
      location_lost: "Campus",
      date_lost: Date.current,
      contact_name: "Admin",
      contact_email: "admin@u.northwestern.edu",
      status: "open"
    )
    assert_difference("LostItem.count", -1) do
      delete lost_item_url(item)
    end

    assert_redirected_to lost_items_url
  end
end
