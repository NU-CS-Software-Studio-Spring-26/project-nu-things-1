# frozen_string_literal: true

require "test_helper"

class UserProfileAvatarTest < ActiveSupport::TestCase
  test "accepts valid profile avatars" do
    user = users(:nu_student)
    ProfileAvatars::AVATARS.each_key do |avatar|
      user.profile_avatar = avatar
      assert user.valid?, "expected #{avatar} to be valid"
    end
  end

  test "rejects invalid profile avatar" do
    user = users(:nu_student)
    user.profile_avatar = "dragon"
    assert_not user.valid?
    assert_includes user.errors[:profile_avatar], "is not included in the list"
  end

  test "profile_avatar_initial is true for blank or initial selection" do
    user = users(:admin)
    assert user.profile_avatar_initial?

    user.profile_avatar = "initial"
    assert user.profile_avatar_initial?

    user.profile_avatar = "cat"
    assert_not user.profile_avatar_initial?
  end
end
