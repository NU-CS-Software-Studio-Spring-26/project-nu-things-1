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

  test "profile lists rental bookings requested by user" do
    u = users(:nu_student)
    booking = bookings(:future_pending)
    get user_url(u)
    assert_response :success
    assert_select "h2", text: /Rental bookings requested/i
    assert_select "a[href='#{rental_item_path(booking.rental_item)}']", text: booking.rental_item.title
  end

  test "profile shows user reputation summary" do
    u = users(:nu_student)
    get user_url(u)
    assert_response :success
    assert_includes response.body, "User reputation"
    assert_includes response.body, "5.0 / 5"
    assert_includes response.body, "1 rating"
    assert_includes response.body, "exchange ratings from completed handoffs"
    assert_select "img.nu-profile-avatar[src*='profile_avatars/squirrel']"
  end

  test "profile lists exchange ratings with listing links" do
    get user_url(users(:admin))
    assert_response :success
    assert_select "h2", text: /Exchange ratings received/i
    assert_select "a[href='#{rental_item_path(rental_items(:one))}']"
  end

  test "own profile lists blocked users with unblock action" do
    admin = users(:admin)
    student = users(:nu_student)
    admin.block!(student)

    sign_in_as(admin)
    get user_url(admin)
    assert_response :success
    assert_select "button.nu-profile-blocked-toggle", text: /Blocked users \(1\)/i
    assert_select "#profileBlockedUsers.collapse"
    assert_select "a[href='#{user_path(student)}']", text: student.first_name
    assert_select "form[action='#{user_block_path(student)}'] input[name='_method'][value=delete]"
  end

  test "own profile shows empty blocked users state" do
    sign_in_as(users(:admin))
    get user_url(users(:admin))
    assert_response :success
    assert_select "button.nu-profile-blocked-toggle", text: /Blocked users/i
    assert_includes response.body, "You haven't blocked anyone."
  end

  test "other users profile does not show blocked users section" do
    admin = users(:admin)
    admin.block!(users(:nu_student))

    sign_in_as(admin)
    get user_url(users(:nu_student))
    assert_response :success
    assert_select "button.nu-profile-blocked-toggle", count: 0
    assert_select "#profileBlockedUsers", count: 0
  end
end
