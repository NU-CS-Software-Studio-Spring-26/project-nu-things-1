# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "guest can view public profile and response omits Northwestern email address" do
    u = users(:nu_student)
    get user_url(u)
    assert_response :success

    assert_not_includes response.body, u.email
  end

  test "shows not found for unknown user" do
    max_id = User.maximum(:id) || 0
    get user_url(max_id + 9_999)
    assert_response :not_found
  end

  test "signed-in user sees profile nav target" do
    u = users(:nu_student)
    sign_in_as(u)
    get root_url
    assert_response :success
    assert_select "a[href='#{user_path(u)}']", text: /Profile/i
  end
end
