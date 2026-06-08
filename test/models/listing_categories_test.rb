# frozen_string_literal: true

require "test_helper"

class ListingCategoriesTest < ActiveSupport::TestCase
  test "canonical returns case-insensitive match" do
    assert_equal "Electronics", ListingCategories.canonical("electronics")
    assert_equal "Camping Gear", ListingCategories.canonical("camping gear")
  end

  test "display_label maps custom category to canonical value" do
    label = ListingCategories.display_label("Other", custom_category: "electronics")
    assert_equal "Electronics", label
  end

  test "display_label formats custom labels consistently" do
    label = ListingCategories.display_label("Other", custom_category: "school supplies")
    assert_equal "School Supplies", label
  end

  test "filter_options uses shared order with Other last" do
    assert_equal ListingCategories::FILTER_OPTIONS, ListingCategories.filter_options
    assert_equal "Other", ListingCategories.filter_options.last
    assert_equal %w[Accessories Book Camping\ Gear Electronics Furniture Sports\ Equipment Tools Other],
                 ListingCategories.filter_options
  end

  test "group_sort_key places Other after standard categories" do
    ordered = [ "Other", "Electronics", "Keys" ].sort_by { |label| ListingCategories.group_sort_key(label) }
    assert_equal [ "Electronics", "Keys", "Other" ], ordered
  end

  test "slug maps Book to books" do
    assert_equal "books", ListingCategories.slug("Book")
    assert_equal "electronics", ListingCategories.slug("electronics")
  end
end
