require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # OAuth Callback Tests — Email Verification Security
  # ============================================================================

  test "successful login with verified northwestern email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-success-test",
      "info" => { "email" => "success@u.northwestern.edu", "first_name" => "Success" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert session[:user_id].present?
    user = User.find(session[:user_id])
    assert_equal "success@u.northwestern.edu", user.email
  end

  test "rejects login with unverified email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-unverified",
      "info" => { "email" => "unverified@u.northwestern.edu", "first_name" => "Unverified" },
      "extra" => { "raw_info" => { "email_verified" => false } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to new_session_path
    assert_includes flash[:alert], "verified @u.northwestern.edu or @northwestern.edu"
    assert_nil session[:user_id]
  end

  test "rejects login with non-northwestern email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-gmail",
      "info" => { "email" => "hacker@gmail.com", "first_name" => "Hacker" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to new_session_path
    assert_includes flash[:alert], "verified @u.northwestern.edu or @northwestern.edu"
    assert_nil session[:user_id]
  end

  test "rejects login with empty email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-no-email",
      "info" => { "email" => "", "first_name" => "NoEmail" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to new_session_path
    assert_includes flash[:alert], "verified @u.northwestern.edu or @northwestern.edu"
    assert_nil session[:user_id]
  end

  test "successful login with u.northwestern.edu email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-u-domain",
      "info" => { "email" => "student@u.northwestern.edu", "first_name" => "Student" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert session[:user_id].present?
  end

  test "successful login with northwestern.edu email" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-domain",
      "info" => { "email" => "admin@northwestern.edu", "first_name" => "Admin" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert session[:user_id].present?
  end

  test "links to existing user on repeat login" do
    # Create initial user
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-repeat",
      "info" => { "email" => "repeat@u.northwestern.edu", "first_name" => "Repeat" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    # First login
    get "/auth/google_oauth2/callback"
    user_id_1 = User.find(session[:user_id]).id

    # Second login in a new request
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)
    get "/auth/google_oauth2/callback"
    user_id_2 = User.find(session[:user_id]).id

    assert_equal user_id_1, user_id_2, "Should link to same user on repeat login"
  end

  test "rejects nil auth hash" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = nil

    get "/auth/google_oauth2/callback"

    # When auth is nil, from_omniauth returns nil
    assert_redirected_to new_session_path
    assert_includes flash[:alert], "verified @u.northwestern.edu or @northwestern.edu"
    assert_nil session[:user_id]
  end

  test "handles missing email_verified field gracefully" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "google-uid-no-verified-field",
      "info" => { "email" => "missing@u.northwestern.edu", "first_name" => "Missing" },
      "extra" => { "raw_info" => {} }  # No email_verified field
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    get "/auth/google_oauth2/callback"

    # Should succeed because email_verified != false (it's nil/missing)
    assert_redirected_to root_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert session[:user_id].present?
  end

  test "failure callback redirects with alert" do
    get "/auth/failure"

    assert_redirected_to new_session_path
    assert_includes flash[:alert], "Google sign-in did not complete"
  end

  teardown do
    OmniAuth.config.test_mode = false
  end
end
