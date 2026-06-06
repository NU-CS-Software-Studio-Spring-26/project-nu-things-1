require "test_helper"

class MarketplaceListingTest < ActiveSupport::TestCase
  test "requires photo or image URL" do
    listing = marketplace_listings(:for_sale_one)
    listing.image_url = nil
    listing.photo.purge if listing.photo.attached?
    assert_not listing.valid?
    assert listing.errors[:photo].any?
  end

  test "requires core fields" do
    listing = MarketplaceListing.new
    assert_not listing.valid?
    assert listing.errors.of_kind?(:title, :blank)
    assert listing.errors.of_kind?(:description, :blank)
    assert listing.errors.of_kind?(:category, :blank)
    assert listing.errors.of_kind?(:location, :blank)
    assert listing.errors.of_kind?(:listing_type, :blank)
    assert listing.errors.of_kind?(:contact_name, :blank)
    assert listing.errors.of_kind?(:contact_email, :blank)
  end

  test "rejects invalid listing_type" do
    listing = marketplace_listings(:for_sale_one)
    listing.listing_type = "donation"
    assert_not listing.valid?
    assert listing.errors.of_kind?(:listing_type, :inclusion)
  end

  test "accepts allowed listing_types" do
    listing = marketplace_listings(:for_sale_one)
    MarketplaceListing::LISTING_TYPES.each do |type|
      listing.listing_type = type
      listing.price = type == "for_sale" ? 10.00 : nil
      assert listing.valid?, "expected #{type} to be valid"
    end
  end

  test "rejects invalid category" do
    listing = marketplace_listings(:for_sale_one)
    listing.category = "InvalidCategory"
    assert_not listing.valid?
    assert listing.errors.of_kind?(:category, :inclusion)
  end

  test "accepts allowed categories" do
    listing = marketplace_listings(:for_sale_one)
    MarketplaceListing::CATEGORIES.each do |cat|
      listing.category = cat
      listing.custom_category = cat == "Other" ? "My Custom" : nil
      assert listing.valid?, "expected #{cat} to be valid"
    end
  end

  test "rejects invalid status" do
    listing = marketplace_listings(:for_sale_one)
    listing.status = "pending"
    assert_not listing.valid?
    assert listing.errors.of_kind?(:status, :inclusion)
  end

  test "accepts allowed statuses" do
    listing = marketplace_listings(:for_sale_one)
    MarketplaceListing::STATUSES.each do |status|
      listing.status = status
      assert listing.valid?, "expected #{status} to be valid"
    end
  end

  test "requires price for for_sale listing" do
    listing = marketplace_listings(:for_sale_one)
    listing.price = nil
    assert_not listing.valid?
    assert listing.errors[:price].any?
  end

  test "does not require price for wanted listing" do
    listing = marketplace_listings(:wanted_one)
    listing.price = nil
    assert listing.valid?
  end

  test "requires custom_category when category is Other" do
    listing = marketplace_listings(:other_category)
    listing.custom_category = nil
    assert_not listing.valid?
    assert listing.errors[:custom_category].any?
  end

  test "does not require custom_category when category is not Other" do
    listing = marketplace_listings(:for_sale_one)
    listing.custom_category = nil
    assert listing.valid?
  end

  test "defaults status to active when unset on create" do
    listing = MarketplaceListing.create!(
      title: "Test item",
      description: "A description.",
      category: "Book",
      location: "Norris",
      listing_type: "wanted",
      contact_name: "A Student",
      contact_email: "student@u.northwestern.edu",
      status: nil,
      image_url: "https://example.com/listing-photo.jpg"
    )
    assert_equal "active", listing.reload.status
  end

  test "validates email format" do
    listing = marketplace_listings(:for_sale_one)
    listing.contact_email = "not-an-email"
    assert_not listing.valid?
    assert listing.errors.of_kind?(:contact_email, :invalid)
  end

  test "category_label returns custom_category when category is Other" do
    listing = marketplace_listings(:other_category)
    assert_equal "Lighting", listing.category_label
  end

  test "category_label returns category when not Other" do
    listing = marketplace_listings(:for_sale_one)
    assert_equal "Camping Gear", listing.category_label
  end

  test "average_rating and reviews_count from reviews" do
    item = marketplace_listings(:for_sale_one)
    assert_equal 2, item.reviews_count
    assert_in_delta 4.5, item.average_rating, 0.01
  end

  test "no reviews yields nil average and zero count" do
    item = marketplace_listings(:wanted_one)
    assert_equal 0, item.reviews_count
    assert_nil item.average_rating
  end

  test "posted_by matches linked user" do
    listing = marketplace_listings(:for_sale_one)
    assert listing.posted_by?(users(:nu_student))
    assert_not listing.posted_by?(users(:admin))
  end

  test "posted_by matches contact_email when user_id absent" do
    listing = marketplace_listings(:wanted_one)
    user = users(:admin)
    listing.update!(contact_email: user.email)

    assert listing.posted_by?(user)
  end

  test "can_leave_review requires active listing and prior message" do
    listing = marketplace_listings(:for_sale_one)
    admin = users(:admin)

    assert listing.can_leave_review?(admin)

    listing.update!(status: "inactive")
    assert_not listing.can_leave_review?(admin)
  end
end
