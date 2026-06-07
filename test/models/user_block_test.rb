# frozen_string_literal: true

require "test_helper"

class UserBlockTest < ActiveSupport::TestCase
  test "user cannot block themselves" do
    user = users(:admin)
    block = UserBlock.new(blocker: user, blocked: user)

    assert_not block.valid?
    assert block.errors[:blocked].any?
  end

  test "blocking? and blocked_by? reflect relationship" do
    admin = users(:admin)
    student = users(:nu_student)
    admin.block!(student)

    assert admin.blocking?(student)
    assert student.blocked_by?(admin)
    assert_not student.blocking?(admin)
    assert_not admin.blocked_by?(student)
  end
end
