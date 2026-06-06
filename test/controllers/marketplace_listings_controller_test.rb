require "test_helper"

class MarketplaceListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = marketplace_listings(:for_sale_one)
  end

  test "should get index" do
    get marketplace_listings_url
    assert_response :success
  end

  test "index filters by listing_type" do
    get marketplace_listings_url, params: { listing_type: "wanted" }
    assert_response :success
  end

  test "index filters by category" do
    get marketplace_listings_url, params: { category: "Book" }
    assert_response :success
  end

  test "index filters by q" do
    get marketplace_listings_url, params: { q: "Camping Tent" }
    assert_response :success
    assert_select ".nu-item-title", text: "Camping Tent"
    assert_select ".nu-item-title", text: "Calculus Textbook", count: 0
  end

  test "index filters by q and listing_type" do
    get marketplace_listings_url, params: { q: "Calculus", listing_type: "wanted" }
    assert_response :success
    assert_select ".nu-item-title", text: "Calculus Textbook"
  end

  test "index blank q returns all active listings" do
    get marketplace_listings_url, params: { q: "" }
    assert_response :success
    assert_select ".nu-item-title", minimum: 2
  end

  test "index paginates marketplace listings" do
    create_marketplace_listings_for_pagination(10)

    get marketplace_listings_url
    assert_response :success
    assert_select "nav[aria-label='Listing pages']"
    assert_select ".nu-item-title", count: ApplicationController::LISTINGS_PER_PAGE

    get marketplace_listings_url, params: { page: 2 }
    assert_response :success
    assert_select ".nu-item-title", count: 1
  end

  test "index pagination preserves listing_type filter" do
    create_marketplace_listings_for_pagination(11)

    get marketplace_listings_url, params: { listing_type: "for_sale", page: 2 }
    assert_response :success
    assert_select "a.page-link[href*='listing_type=for_sale']"
  end

  test "should redirect new when not signed in" do
    get new_marketplace_listing_url
    assert_redirected_to new_session_url
  end

  test "should get new when signed in" do
    sign_in_as(users(:nu_student))
    get new_marketplace_listing_url
    assert_response :success
  end

  test "should redirect create when not signed in" do
    assert_no_difference("MarketplaceListing.count") do
      post marketplace_listings_url, params: {
        marketplace_listing: {
          title: @listing.title,
          description: @listing.description,
          category: @listing.category,
          condition: @listing.condition,
          image_url: @listing.image_url,
          location: @listing.location,
          listing_type: @listing.listing_type,
          price: @listing.price,
          contact_name: @listing.contact_name,
          contact_email: @listing.contact_email,
          contact_phone: @listing.contact_phone,
          custom_category: @listing.custom_category,
          status: @listing.status
        }
      }
    end
    assert_redirected_to new_session_url
  end

  test "should create marketplace_listing when signed in" do
    sign_in_as(users(:nu_student))
    assert_difference("MarketplaceListing.count") do
      post marketplace_listings_url, params: {
        marketplace_listing: {
          title: @listing.title,
          description: @listing.description,
          category: @listing.category,
          condition: @listing.condition,
          image_url: @listing.image_url,
          location: @listing.location,
          listing_type: @listing.listing_type,
          price: @listing.price,
          contact_name: @listing.contact_name,
          contact_email: @listing.contact_email,
          contact_phone: @listing.contact_phone,
          custom_category: @listing.custom_category,
          status: @listing.status
        }
      }
    end

    assert_redirected_to marketplace_listing_url(MarketplaceListing.last)
    assert_equal users(:nu_student).id, MarketplaceListing.last.user_id
  end

  test "should show marketplace_listing" do
    get marketplace_listing_url(@listing)
    assert_response :success
  end

  test "should redirect edit when not signed in" do
    get edit_marketplace_listing_url(@listing)
    assert_redirected_to new_session_url
  end

  test "should redirect edit when signed in but not owner of legacy listing" do
    sign_in_as(users(:nu_student))
    get edit_marketplace_listing_url(marketplace_listings(:wanted_one))
    assert_redirected_to root_url
  end

  test "should get edit when signed in as owner" do
    sign_in_as(users(:nu_student))
    get edit_marketplace_listing_url(@listing)
    assert_response :success
  end

  test "should get edit when admin" do
    sign_in_as(users(:admin))
    get edit_marketplace_listing_url(marketplace_listings(:wanted_one))
    assert_response :success
  end

  test "should redirect update when not owner on legacy listing" do
    sign_in_as(users(:nu_student))
    legacy = marketplace_listings(:wanted_one)
    patch marketplace_listing_url(legacy), params: {
      marketplace_listing: {
        title: legacy.title,
        description: legacy.description,
        category: legacy.category,
        condition: legacy.condition,
        image_url: legacy.image_url,
        location: legacy.location,
        listing_type: legacy.listing_type,
        price: legacy.price,
        contact_name: legacy.contact_name,
        contact_email: legacy.contact_email,
        contact_phone: legacy.contact_phone,
        custom_category: legacy.custom_category,
        status: legacy.status
      }
    }
    assert_redirected_to root_url
  end

  test "should update own marketplace_listing when signed in" do
    sign_in_as(users(:nu_student))
    patch marketplace_listing_url(@listing), params: {
      marketplace_listing: {
        title: @listing.title,
        description: "Updated by owner.",
        category: @listing.category,
        condition: @listing.condition,
        image_url: @listing.image_url,
        location: @listing.location,
        listing_type: @listing.listing_type,
        price: @listing.price,
        contact_name: @listing.contact_name,
        contact_email: @listing.contact_email,
        contact_phone: @listing.contact_phone,
        custom_category: @listing.custom_category,
        status: @listing.status
      }
    }
    assert_redirected_to marketplace_listing_url(@listing)
    assert_equal "Updated by owner.", @listing.reload.description
  end

  test "should update marketplace_listing when admin" do
    sign_in_as(users(:admin))
    legacy = marketplace_listings(:wanted_one)
    patch marketplace_listing_url(legacy), params: {
      marketplace_listing: {
        title: legacy.title,
        description: "Updated by admin.",
        category: legacy.category,
        condition: legacy.condition,
        image_url: legacy.image_url,
        location: legacy.location,
        listing_type: legacy.listing_type,
        price: legacy.price,
        contact_name: legacy.contact_name,
        contact_email: legacy.contact_email,
        contact_phone: legacy.contact_phone,
        custom_category: legacy.custom_category,
        status: legacy.status
      }
    }
    assert_redirected_to marketplace_listing_url(legacy)
    assert_equal "Updated by admin.", legacy.reload.description
  end

  test "should redirect destroy when not admin" do
    sign_in_as(users(:nu_student))
    assert_no_difference("MarketplaceListing.count") do
      delete marketplace_listing_url(@listing)
    end
    assert_redirected_to root_url
  end

  test "should destroy marketplace_listing when admin" do
    sign_in_as(users(:admin))
    listing = marketplace_listings(:wanted_one)
    assert_difference("MarketplaceListing.count", -1) do
      delete marketplace_listing_url(listing)
    end

    assert_redirected_to marketplace_listings_url
  end
end
