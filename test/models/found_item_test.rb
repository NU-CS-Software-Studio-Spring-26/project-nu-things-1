require "test_helper"

class FoundItemTest < ActiveSupport::TestCase
  test "requires core fields" do
    item = FoundItem.new
    assert_not item.valid?
    assert item.errors.of_kind?(:title, :blank)
    assert item.errors.of_kind?(:description, :blank)
    assert item.errors.of_kind?(:category, :blank)
    assert item.errors.of_kind?(:location_found, :blank)
    assert item.errors.of_kind?(:date_found, :blank)
    assert item.errors.of_kind?(:contact_name, :blank)
    assert item.errors.of_kind?(:contact_email, :blank)
  end

  test "rejects invalid status" do
    item = found_items(:one)
    item.status = "lost"
    assert_not item.valid?
    assert item.errors.of_kind?(:status, :inclusion)
  end

  test "accepts allowed statuses" do
    item = found_items(:one)
    FoundItem::STATUSES.each do |status|
      item.status = status
      assert item.valid?, "expected #{status} to be valid"
    end
  end

  test "defaults status to unclaimed when unset on create" do
    item = FoundItem.create!(
      title: "Umbrella",
      description: "Black compact umbrella.",
      category: "Accessories",
      location_found: "Tech lobby",
      date_found: Date.current,
      contact_name: "A Finder",
      contact_email: "finder@u.northwestern.edu",
      status: nil
    )
    assert_equal "unclaimed", item.reload.status
  end

  test "validates email format" do
    item = found_items(:one)
    item.contact_email = "bad"
    assert_not item.valid?
    assert item.errors.of_kind?(:contact_email, :invalid)
  end
end
