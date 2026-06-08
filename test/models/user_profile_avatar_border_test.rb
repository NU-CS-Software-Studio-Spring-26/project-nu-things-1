# frozen_string_literal: true

require "test_helper"

class UserProfileAvatarBorderTest < ActiveSupport::TestCase
  test "accepts valid border styles and colors" do
    user = users(:nu_student)
    user.profile_avatar_border_style = "dashed"
    user.profile_avatar_border_color = "pink"
    assert user.valid?
  end

  test "rejects invalid border settings" do
    user = users(:nu_student)
    user.profile_avatar_border_style = "dotted"
    assert_not user.valid?

    user.profile_avatar_border_style = "regular"
    user.profile_avatar_border_color = "green"
    assert_not user.valid?
  end

  test "default style clears border color" do
    user = users(:nu_student)
    user.profile_avatar_border_style = "default"
    user.profile_avatar_border_color = "pink"
    user.valid?

    assert_nil user.profile_avatar_border_color
    assert user.profile_avatar_border_default?
  end

  test "non-default style defaults color to purple when blank" do
    user = users(:nu_student)
    user.profile_avatar_border_style = "regular"
    user.profile_avatar_border_color = nil
    user.valid?

    assert_equal "purple", user.profile_avatar_border_color
  end
end
