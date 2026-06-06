# frozen_string_literal: true

require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "requires action and subject" do
    log = AuditLog.new
    assert_not log.valid?
    assert_includes log.errors[:action], "can't be blank"
    assert_includes log.errors[:subject], "can't be blank"
  end

  test "allows guest user" do
    log = AuditLog.create!(action: "lost_item.report", subject: "Test item")
    assert_nil log.user
    assert log.persisted?
  end
end
