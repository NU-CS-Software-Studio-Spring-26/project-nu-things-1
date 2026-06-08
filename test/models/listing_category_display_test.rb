# frozen_string_literal: true

require "test_helper"

class ListingCategoryDisplayTest < ActiveSupport::TestCase
  test "promotes Other with canonical custom category to standard category" do
    item = LostItem.new(
      title: "Test item",
      description: "Description",
      category: "Other",
      custom_category: "electronics",
      location_lost: "Campus",
      date_lost: Date.current,
      contact_name: "Student",
      contact_email: "student@u.northwestern.edu",
      status: "open"
    )

    assert item.valid?
    assert_equal "Electronics", item.category
    assert_nil item.custom_category
    assert_equal "Electronics", item.category_label
  end

  test "rental items expose category_label" do
    item = rental_items(:one)
    assert_equal item.category, item.category_label
  end
end
