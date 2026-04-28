require "test_helper"

class FoundItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @found_item = found_items(:one)
  end

  test "should get index" do
    get found_items_url
    assert_response :success
  end

  test "should get new" do
    get new_found_item_url
    assert_response :success
  end

  test "should create found_item" do
    assert_difference("FoundItem.count") do
      post found_items_url, params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: @found_item.description, image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    end

    assert_redirected_to found_item_url(FoundItem.last)
  end

  test "should show found_item" do
    get found_item_url(@found_item)
    assert_response :success
  end

  test "edit is not accessible without owner token" do
    get "/found_items/#{@found_item.id}/edit"
    assert_response :not_found
  end

  test "update is not accessible without owner token" do
    patch "/found_items/#{@found_item.id}", params: { found_item: { title: "X" } }
    assert_response :not_found
  end

  test "destroy is not accessible without owner token" do
    assert_no_difference("FoundItem.count") do
      delete "/found_items/#{@found_item.id}"
      assert_response :not_found
    end
  end
end
