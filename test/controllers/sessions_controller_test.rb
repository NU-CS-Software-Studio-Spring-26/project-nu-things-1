require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new stores safe return_to from query string" do
    get new_session_url, params: { return_to: "/lost_items/new" }
    assert_response :success
    assert_equal "/lost_items/new", session[:return_to]
  end

  test "new ignores unsafe return_to" do
    get new_session_url, params: { return_to: "https://evil.example/phish" }
    assert_response :success
    assert_nil session[:return_to]
  end

  test "new ignores unknown path return_to" do
    get new_session_url, params: { return_to: "/admin/secret" }
    assert_response :success
    assert_nil session[:return_to]
  end

  test "create redirects to return_to from posted hidden field" do
    post session_url, params: {
      email: users(:nu_student).email,
      password: "password",
      return_to: "/rental_items/new"
    }
    assert_redirected_to new_rental_item_url
  end

  test "create saves optional first name on sign in" do
    user = users(:nu_student)
    user.update_column(:first_name, nil)

    post session_url, params: {
      email: user.email,
      password: "password",
      first_name: "Jordan"
    }
    assert_redirected_to root_url
    assert_equal "Jordan", user.reload.first_name
  end
end
