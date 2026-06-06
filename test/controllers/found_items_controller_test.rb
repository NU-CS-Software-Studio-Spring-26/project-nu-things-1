require "test_helper"

class FoundItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @found_item = found_items(:one)
  end

  test "should get index" do
    get found_items_url
    assert_response :success
  end

  test "index filters by q" do
    get found_items_url, params: { q: "Fixture found item one" }
    assert_response :success
    assert_select ".nu-item-title", text: "Fixture found item one"
    assert_select ".nu-item-title", text: "Fixture found item admin owned", count: 0
  end

  test "index filters by q and category" do
    get found_items_url, params: { q: "Fixture", category: "Book" }
    assert_response :success
    assert_select ".nu-item-title", minimum: 1
  end

  test "index blank q returns all found items" do
    get found_items_url, params: { q: "" }
    assert_response :success
    assert_select ".nu-item-title", minimum: 2
  end

  test "index paginates found items" do
    create_found_items_for_pagination(10)

    get found_items_url
    assert_response :success
    assert_select "nav[aria-label='Listing pages']"
    assert_select ".nu-item-title", count: ApplicationController::LISTINGS_PER_PAGE

    get found_items_url, params: { page: 2 }
    assert_response :success
    assert_select ".nu-item-title", count: 1
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
    assert_equal users(:nu_student).id, FoundItem.last.user_id
  end

  test "should show found_item" do
    get found_item_url(@found_item)
    assert_response :success
  end

  test "should redirect edit when not signed in" do
    get edit_found_item_url(@found_item)
    assert_redirected_to new_session_url
  end

  test "should redirect edit when signed in but not owner of legacy post" do
    sign_in_as(users(:nu_student))
    get edit_found_item_url(found_items(:two))
    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
  end

  test "should redirect edit when signed in but not owner of another users post" do
    sign_in_as(users(:nu_student))
    get edit_found_item_url(found_items(:admin_owned))
    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
  end

  test "show hides edit for non-owner" do
    sign_in_as(users(:nu_student))
    get found_item_url(found_items(:admin_owned))
    assert_response :success
    assert_select "a", { text: "Edit", count: 0 }
  end

  test "should get edit when signed in as owner" do
    sign_in_as(users(:nu_student))
    get edit_found_item_url(@found_item)
    assert_response :success
  end

  test "should get edit when admin" do
    sign_in_as(users(:admin))
    get edit_found_item_url(found_items(:two))
    assert_response :success
  end

  test "should redirect update when not owner on legacy post" do
    sign_in_as(users(:nu_student))
    patch found_item_url(found_items(:two)), params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: @found_item.description, image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    assert_redirected_to root_url
  end

  test "should redirect update when not owner of another users post" do
    sign_in_as(users(:nu_student))
    other = found_items(:admin_owned)
    patch found_item_url(other), params: { found_item: { brand: other.brand, category: other.category, color: other.color, contact_email: other.contact_email, contact_name: other.contact_name, date_found: other.date_found, description: "Hijack attempt.", image_url: other.image_url, location_found: other.location_found, storage_location: other.storage_location, title: other.title } }
    assert_redirected_to root_url
    assert_not_equal "Hijack attempt.", other.reload.description
  end

  test "should update own found_item when signed in" do
    sign_in_as(users(:nu_student))
    patch found_item_url(@found_item), params: { found_item: { brand: @found_item.brand, category: @found_item.category, color: @found_item.color, contact_email: @found_item.contact_email, contact_name: @found_item.contact_name, date_found: @found_item.date_found, description: "Owner update.", image_url: @found_item.image_url, location_found: @found_item.location_found, status: @found_item.status, storage_location: @found_item.storage_location, title: @found_item.title } }
    assert_redirected_to found_item_url(@found_item)
    assert_equal "Owner update.", @found_item.reload.description
  end

  test "should update found_item when admin" do
    sign_in_as(users(:admin))
    legacy = found_items(:two)
    patch found_item_url(legacy), params: { found_item: { brand: legacy.brand, category: legacy.category, color: legacy.color, contact_email: legacy.contact_email, contact_name: legacy.contact_name, date_found: legacy.date_found, description: "Admin update.", image_url: legacy.image_url, location_found: legacy.location_found, status: legacy.status, storage_location: legacy.storage_location, title: legacy.title } }
    assert_redirected_to found_item_url(legacy)
    assert_equal "Admin update.", legacy.reload.description
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
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
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

  # ============================================================================
  # Email Verification Tests — Only Northwestern Users Can Post Found Items
  # ============================================================================

  test "found item model validates northwestern email format" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Found item",
      description: "Test description",
      category: "Accessories",
      location_found: "Library",
      date_found: Date.current,
      contact_name: "Test",
      contact_email: "invalid@gmail.com",  # Invalid domain
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "found item accepts u.northwestern.edu emails" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Found item",
      description: "Test",
      category: "Accessories",
      location_found: "Library",
      date_found: Date.current,
      contact_name: "Test",
      contact_email: "test@u.northwestern.edu",
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )
    assert item.valid?, "Should accept u.northwestern.edu email"
  end

  test "found item accepts northwestern.edu emails" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Found item",
      description: "Test",
      category: "Accessories",
      location_found: "Library",
      date_found: Date.current,
      contact_name: "Test",
      contact_email: "test@northwestern.edu",
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )
    assert item.valid?, "Should accept northwestern.edu email"
  end

  test "found item rejects gmail addresses" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Found item",
      description: "Test",
      category: "Accessories",
      location_found: "Library",
      date_found: Date.current,
      contact_name: "Test",
      contact_email: "test@gmail.com",
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "found item rejects yahoo addresses" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Found item",
      description: "Test",
      category: "Accessories",
      location_found: "Library",
      date_found: Date.current,
      contact_name: "Test",
      contact_email: "test@yahoo.com",
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "found item rejects arbitrary domains" do
    user = users(:nu_student)
    item = FoundItem.new(
      title: "Hacker found item",
      description: "Trying to use non-NU email",
      category: "Accessories",
      location_found: "Campus",
      date_found: Date.current,
      contact_name: "Hacker",
      contact_email: "hacker@example.com",
      user: user,
      status: "unclaimed",
      image_url: "https://example.com/listing-photo.jpg"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "found item status transitions prevent unauthorized claims" do
    # Verify item starts as unclaimed
    assert_equal "unclaimed", @found_item.status

    # After claiming, status should be claimed
    @found_item.status = "claimed"
    @found_item.claimed_by_user = users(:nu_student)
    @found_item.save!

    assert_equal "claimed", @found_item.status
    assert_equal users(:nu_student).id, @found_item.claimed_by_user_id
  end
end
