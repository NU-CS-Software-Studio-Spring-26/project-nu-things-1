# frozen_string_literal: true

require "test_helper"

class ProfileAvatarsControllerTest < ActionDispatch::IntegrationTest
  test "guest cannot update profile avatar" do
    patch profile_avatar_path, params: { user: { profile_avatar: "cat" } }
    assert_redirected_to new_session_path
  end

  test "signed-in user can set profile avatar" do
    sign_in_as(users(:nu_student))

    patch profile_avatar_path, params: { user: { profile_avatar: "cat" } }

    assert_redirected_to user_path(users(:nu_student))
    assert_equal "cat", users(:nu_student).reload.profile_avatar
  end

  test "rejects invalid profile avatar" do
    student = users(:nu_student)
    sign_in_as(student)

    patch profile_avatar_path, params: { user: { profile_avatar: "dragon" } }

    assert_redirected_to user_path(student)
    assert_equal "squirrel", student.reload.profile_avatar
  end

  test "own profile shows avatar picker" do
    sign_in_as(users(:nu_student))
    get user_url(users(:nu_student))

    assert_response :success
    assert_select "h2", text: /Profile picture/i
    assert_select "input[type=radio][name='user[profile_avatar]'][value=cat]"
    assert_select "img[src*='profile_avatars/cat']"
  end

  test "other users profile does not show avatar picker" do
    sign_in_as(users(:admin))
    get user_url(users(:nu_student))

    assert_response :success
    assert_select "h2", text: /Profile picture/i, count: 0
  end
end
