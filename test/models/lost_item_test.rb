require "test_helper"

class LostItemTest < ActiveSupport::TestCase
  test "requires core fields" do
    item = LostItem.new
    assert_not item.valid?
    assert item.errors.of_kind?(:title, :blank)
    assert item.errors.of_kind?(:description, :blank)
    assert item.errors.of_kind?(:category, :blank)
    assert item.errors.of_kind?(:location_lost, :blank)
    assert item.errors.of_kind?(:date_lost, :blank)
    assert item.errors.of_kind?(:contact_name, :blank)
    assert item.errors.of_kind?(:contact_email, :blank)
  end

  test "rejects invalid status" do
    item = lost_items(:one)
    item.status = "pending"
    assert_not item.valid?
    assert item.errors.of_kind?(:status, :inclusion)
  end

  test "accepts allowed statuses" do
    item = lost_items(:one)
    LostItem::STATUSES.each do |status|
      item.status = status
      assert item.valid?, "expected #{status} to be valid"
    end
  end

  test "defaults status to open when unset on create" do
    item = LostItem.create!(
      title: "Test keys",
      description: "Small key ring.",
      category: "Accessories",
      location_lost: "Norris",
      date_lost: Date.current,
      contact_name: "A Student",
      contact_email: "student@u.northwestern.edu",
      status: nil
    )
    assert_equal "open", item.reload.status
  end

  test "validates email format" do
    item = lost_items(:one)
    item.contact_email = "not-an-email"
    assert_not item.valid?
    assert item.errors.of_kind?(:contact_email, :invalid)
  end

  test "enforces title, name, and description limits" do
    item = lost_items(:one)
    item.title = "x" * (ListingTextLimits::TITLE_MAX_LENGTH + 1)
    assert_not item.valid?
    assert item.errors.of_kind?(:title, :too_long)

    item.title = "ok"
    item.contact_name = "n" * (ListingTextLimits::NAME_MAX_LENGTH + 1)
    assert_not item.valid?
    assert item.errors[:contact_name].any?

    item.contact_name = "ok"
    item.description = ([ "word" ] * (ListingTextLimits::DESCRIPTION_MAX_WORDS + 1)).join(" ")
    assert_not item.valid?
    assert item.errors[:description].any?
  end

  test "rejects moderated word in title" do
    item = lost_items(:one)
    item.title = "Item xxtestbadxx found"
    assert_not item.valid?
    msg = Moderate.configuration.error_message
    assert_includes item.errors[:title], msg
  end
end
