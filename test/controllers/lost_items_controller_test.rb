require "test_helper"

class LostItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lost_item = lost_items(:one)
  end

  # ============================================================================
  # Email Verification Tests — Only Northwestern Users Can Post
  # ============================================================================

  test "should get index without authentication" do
    get lost_items_url
    assert_response :success
  end

  test "index displays lost items from all verified users" do
    get lost_items_url
    assert_response :success
    assert_select "h2", /Lost items/i
    # Should show lost items
    assert_select "[class~=card]"
  end

  test "index filters by q" do
    get lost_items_url, params: { q: "Fixture lost item one" }
    assert_response :success
    assert_select ".nu-item-title", text: "Fixture lost item one"
    assert_select ".nu-item-title", text: "Fixture lost item two", count: 0
    assert_select "p[aria-live=polite]", text: "1 result found for 'Fixture lost item one'"
  end

  test "index filters by q and category" do
    get lost_items_url, params: { q: "Fixture", category: "Book" }
    assert_response :success
    assert_select ".nu-item-title", minimum: 1
  end

  test "index blank q returns all lost items" do
    get lost_items_url, params: { q: "" }
    assert_response :success
    assert_select ".nu-item-title", minimum: 2
  end

  test "index groups items by category when all categories selected" do
    LostItem.create!(
      title: "Grouped electronics item",
      description: "For category grouping test.",
      category: "Electronics",
      location_lost: "Campus",
      date_lost: Date.new(2026, 4, 1),
      contact_name: "Test User",
      contact_email: "lost_one@u.northwestern.edu",
      status: "open"
    )

    get lost_items_url
    assert_response :success
    assert_select "section.nu-listing-category-group"
    assert_select "section.nu-listing-category-group h3", text: /Book \(/
    assert_select "section.nu-listing-category-group h3", text: /Electronics \(/
    assert_select "nav[aria-label='Listing pages']", count: 0
  end

  test "index paginates lost items when category filter is active" do
    create_lost_items_for_pagination(10)

    get lost_items_url, params: { category: "Book" }
    assert_response :success
    assert_select "nav[aria-label='Listing pages']"
    assert_select ".nu-item-title", count: ApplicationController::LISTINGS_PER_PAGE

    get lost_items_url, params: { category: "Book", page: 2 }
    assert_response :success
    assert_select ".nu-item-title", count: 2
  end

  test "index pagination preserves search query" do
    create_lost_items_for_pagination(13)

    get lost_items_url, params: { q: "Pagination", page: 2 }
    assert_response :success
    assert_select "a.page-link[href*='q=Pagination']"
    assert_select "p[aria-live=polite]", text: /13 results found for 'Pagination'/
    assert_select ".nu-item-title", count: 1
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

  test "should redirect resolve when not signed in" do
    post resolve_lost_item_url(@lost_item)
    assert_redirected_to new_session_url
  end

  test "owner can resolve open lost item" do
    sign_in_as(users(:nu_student))
    assert_equal "open", @lost_item.status

    post resolve_lost_item_url(@lost_item)

    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "resolved", @lost_item.reload.status
    assert_match(/marked as resolved/i, flash[:notice].to_s)
  end

  test "non-owner cannot resolve lost item" do
    sign_in_as(users(:nu_student))
    post resolve_lost_item_url(lost_items(:admin_owned))

    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
    assert_equal "open", lost_items(:admin_owned).reload.status
  end

  test "cannot resolve already resolved lost item" do
    sign_in_as(users(:nu_student))
    @lost_item.update!(status: "resolved")

    post resolve_lost_item_url(@lost_item)

    assert_redirected_to lost_item_url(@lost_item)
    assert_match(/already resolved/i, flash[:alert].to_s)
    assert_equal "resolved", @lost_item.reload.status
  end

  test "show displays Mark as resolved for owner when open" do
    sign_in_as(users(:nu_student))
    get lost_item_url(@lost_item)
    assert_response :success
    assert_select "button", { text: "Mark as resolved", count: 1 }
  end

  test "show hides Mark as resolved when already resolved" do
    sign_in_as(users(:nu_student))
    @lost_item.update!(status: "resolved")
    get lost_item_url(@lost_item)
    assert_response :success
    assert_select "button", { text: "Mark as resolved", count: 0 }
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

  test "should redirect edit when signed in but not owner of another users post" do
    sign_in_as(users(:nu_student))
    get edit_lost_item_url(lost_items(:admin_owned))
    assert_redirected_to root_url
    assert_match(/permission/i, flash[:alert].to_s)
  end

  test "show hides edit for non-owner" do
    sign_in_as(users(:nu_student))
    get lost_item_url(lost_items(:admin_owned))
    assert_response :success
    assert_select "a", { text: "Edit", count: 0 }
    assert_select "button", { text: "Delete", count: 0 }
    assert_select ".nu-listing-contact-identity .nu-profile-avatar"
    assert_includes response.body, lost_items(:admin_owned).contact_name
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

  test "should redirect update when not owner of another users post" do
    sign_in_as(users(:nu_student))
    other = lost_items(:admin_owned)
    patch lost_item_url(other), params: { lost_item: { brand: other.brand, category: other.category, color: other.color, contact_email: other.contact_email, contact_name: other.contact_name, date_lost: other.date_lost, description: "Hijack attempt.", image_url: other.image_url, location_lost: other.location_lost, reward: other.reward, status: other.status, title: other.title } }
    assert_redirected_to root_url
    assert_not_equal "Hijack attempt.", other.reload.description
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
      assert_difference("AuditLog.count", 1) do
        delete lost_item_url(item)
      end
    end

    log = AuditLog.order(:id).last
    assert_equal "lost_item.destroy", log.action
    assert_equal "Delete me", log.subject
    assert_equal users(:admin), log.user

    assert_redirected_to lost_items_url
  end

  # ============================================================================
  # Extended Email Verification Tests — Ensuring Only NU Users Can Post
  # ============================================================================

  test "lost item model validates northwestern email format" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Test item",
      description: "Test description",
      category: "Keys",
      location_lost: "Library",
      date_lost: Date.current,
      contact_name: "Test",
      contact_email: "invalid@gmail.com",  # Invalid domain
      user: user,
      status: "open"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "lost item accepts u.northwestern.edu emails" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Test item",
      description: "Test",
      category: "Accessories",
      location_lost: "Library",
      date_lost: Date.current,
      contact_name: "Test",
      contact_email: "test@u.northwestern.edu",
      user: user,
      status: "open"
    )
    assert item.valid?, "Should accept u.northwestern.edu email"
  end

  test "lost item accepts northwestern.edu emails" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Test item",
      description: "Test",
      category: "Accessories",
      location_lost: "Library",
      date_lost: Date.current,
      contact_name: "Test",
      contact_email: "test@northwestern.edu",
      user: user,
      status: "open"
    )
    assert item.valid?, "Should accept northwestern.edu email"
  end

  test "lost item rejects gmail addresses" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Test item",
      description: "Test",
      category: "Accessories",
      location_lost: "Library",
      date_lost: Date.current,
      contact_name: "Test",
      contact_email: "test@gmail.com",
      user: user,
      status: "open"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "lost item rejects yahoo addresses" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Test item",
      description: "Test",
      category: "Accessories",
      location_lost: "Library",
      date_lost: Date.current,
      contact_name: "Test",
      contact_email: "test@yahoo.com",
      user: user,
      status: "open"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end

  test "lost item rejects arbitrary domains" do
    user = users(:nu_student)
    item = LostItem.new(
      title: "Hacker attempt",
      description: "Trying to use non-NU email",
      category: "Accessories",
      location_lost: "Campus",
      date_lost: Date.current,
      contact_name: "Hacker",
      contact_email: "hacker@example.com",
      user: user,
      status: "open"
    )

    assert_not item.valid?
    assert item.errors[:contact_email].any?
  end
end
