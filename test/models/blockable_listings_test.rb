# frozen_string_literal: true

require "test_helper"

class BlockableListingsTest < ActiveSupport::TestCase
  test "visible_to hides listings from users who blocked the viewer" do
    student = users(:nu_student)
    admin = users(:admin)
    admin.block!(student)
    admin_listing = lost_items(:admin_owned)

    visible_ids = LostItem.visible_to(student).pluck(:id)

    assert_not_includes visible_ids, admin_listing.id
    assert_not admin_listing.visible_to?(student)
  end

  test "visible_to shows all listings to guests" do
    assert_includes LostItem.visible_to(nil).pluck(:id), lost_items(:admin_owned).id
  end

  test "viewable_to allows blocked renter to view rental with prior booking" do
    student = users(:nu_student)
    admin = users(:admin)
    admin.block!(student)
    rental = rental_items(:one)

    assert_not rental.visible_to?(student)
    assert rental.viewable_to?(student)
    assert rental.accessible_with_prior_interaction?(student)
  end

  test "viewable_to still blocks rental when renter has no prior booking" do
    student = users(:nu_student)
    admin = users(:admin)
    admin.block!(student)
    rental = RentalItem.create!(
      title: "Blocked-only rental",
      description: "No prior bookings with student.",
      category: "Book",
      rental_price: 10,
      rental_period: "per_day",
      condition: "Good",
      location: "Evanston campus",
      available_from: Date.new(2026, 5, 1),
      available_to: Date.new(2026, 12, 31),
      owner_name: admin.first_name,
      owner_email: admin.email,
      user: admin,
      status: "available",
      image_url: "https://example.com/listing-photo.jpg"
    )

    assert_not rental.visible_to?(student)
    assert_not rental.viewable_to?(student)
  end
end
