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

  test "google oauth callback redirects to return_to from session" do
    get new_session_url, params: { return_to: "/rental_items/new" }
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "oauth-return-to-test",
      "info" => { "email" => users(:nu_student).email, "first_name" => "Jordan" }
    )
    get "/auth/google_oauth2/callback"
    assert_redirected_to new_rental_item_url
  end

  test "google oauth callback saves first name when blank" do
    user = users(:nu_student)
    user.update_column(:first_name, nil)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "oauth-fn-test",
      "info" => { "email" => user.email, "first_name" => "Jordan" }
    )
    get "/auth/google_oauth2/callback"
    assert_redirected_to root_url
    assert_equal "Jordan", user.reload.first_name
  end
end
