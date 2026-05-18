# frozen_string_literal: true

require "test_helper"

class ListingAuthorizableTest < ActiveSupport::TestCase
  test "editable_by? is true for owner and admin only" do
    item = lost_items(:one)
    assert item.editable_by?(users(:nu_student))
    assert item.editable_by?(users(:admin))

    admin_item = lost_items(:admin_owned)
    assert admin_item.editable_by?(users(:admin))
    assert_not admin_item.editable_by?(users(:nu_student))
  end

  test "legacy post without user_id is editable only by admin" do
    legacy = lost_items(:two)
    assert legacy.editable_by?(users(:admin))
    assert_not legacy.editable_by?(users(:nu_student))
  end

  test "user_id cannot be changed after create" do
    item = lost_items(:one)
    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      item.user_id = users(:admin).id
    end
  end
end
