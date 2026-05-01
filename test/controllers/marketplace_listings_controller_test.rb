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
    get marketplace_listings_url, params: { category: "Books" }
    assert_response :success
  end

  test "should get new" do
    get new_marketplace_listing_url
    assert_response :success
  end

  test "should create marketplace_listing" do
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
  end

  test "should show marketplace_listing" do
    get marketplace_listing_url(@listing)
    assert_response :success
  end

  test "should get edit" do
    get edit_marketplace_listing_url(@listing)
    assert_response :success
  end

  test "should update marketplace_listing" do
    patch marketplace_listing_url(@listing), params: {
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
    assert_redirected_to marketplace_listing_url(@listing)
  end

  test "should destroy marketplace_listing" do
    assert_difference("MarketplaceListing.count", -1) do
      delete marketplace_listing_url(@listing)
    end

    assert_redirected_to marketplace_listings_url
  end
end
