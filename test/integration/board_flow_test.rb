require "test_helper"

class BoardFlowTest < ActionDispatch::IntegrationTest
  test "home and index pages load" do
    get root_url
    assert_response :success

    get lost_items_url
    assert_response :success

    get found_items_url
    assert_response :success
  end

  test "lost item lifecycle" do
    item = lost_items(:one)
    get lost_item_url(item)
    assert_response :success

    assert_difference("LostItem.count", 1) do
      post lost_items_url, params: {
        lost_item: {
          title: "Integration test keys",
          description: "Small ring with two keys.",
          category: "Keys",
          location_lost: "Norris ground floor",
          date_lost: Date.new(2026, 4, 20),
          contact_name: "Flow Tester",
          contact_email: "flow.tester@example.com",
          status: "open",
          image_url: "",
          reward: "",
          color: "Silver",
          brand: ""
        }
      }
    end
    assert_redirected_to lost_item_path(LostItem.order(:id).last)

    new_item = LostItem.find_by!(title: "Integration test keys")
    patch "/lost_items/#{new_item.id}", params: { lost_item: { status: "resolved" } }
    assert_response :not_found

    assert_no_difference("LostItem.count") do
      delete "/lost_items/#{new_item.id}"
      assert_response :not_found
    end
  end

  test "found item lifecycle" do
    item = found_items(:one)
    get found_item_url(item)
    assert_response :success

    assert_difference("FoundItem.count", 1) do
      post found_items_url, params: {
        found_item: {
          title: "Integration test umbrella",
          description: "Compact black umbrella.",
          category: "Accessories",
          location_found: "Tech entrance",
          date_found: Date.new(2026, 4, 20),
          contact_name: "Finder Flow",
          contact_email: "finder.flow@example.com",
          status: "unclaimed",
          image_url: "",
          storage_location: "Tech desk",
          color: "Black",
          brand: ""
        }
      }
    end
    assert_redirected_to found_item_path(FoundItem.order(:id).last)

    new_item = FoundItem.find_by!(title: "Integration test umbrella")
    patch "/found_items/#{new_item.id}", params: { found_item: { status: "claimed" } }
    assert_response :not_found

    assert_no_difference("FoundItem.count") do
      delete "/found_items/#{new_item.id}"
      assert_response :not_found
    end
  end
end
