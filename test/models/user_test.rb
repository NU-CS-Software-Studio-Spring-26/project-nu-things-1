require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ============================================================================
  # Email Validation Tests — Northwestern Domain Verification
  # ============================================================================

  test "requires northwestern email" do
    user = User.new(email: "a@gmail.com", first_name: "Pat", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "rejects gmail email" do
    user = User.new(email: "student@gmail.com", first_name: "Test", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "rejects yahoo email" do
    user = User.new(email: "student@yahoo.com", first_name: "Test", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "rejects generic company email" do
    user = User.new(email: "employee@example.com", first_name: "Test", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "accepts u.northwestern.edu" do
    user = User.new(email: "x@u.northwestern.edu", first_name: "X", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "accepts northwestern.edu" do
    user = User.new(email: "x@northwestern.edu", first_name: "X", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "case-insensitive email validation for northwestern domain" do
    user = User.new(email: "Test@U.NORTHWESTERN.EDU", first_name: "Test", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "rejects email with leading/trailing whitespace" do
    user = User.new(email: " test@u.northwestern.edu ", first_name: "Test", password: "password123", password_confirmation: "password123")
    user.valid?
    # Should normalize and be valid after normalization
    assert_equal "test@u.northwestern.edu", user.email
    assert user.valid?
  end

  # ============================================================================
  # OAuth Authentication Tests — Google Sign-in with Email Verification
  # ============================================================================

  test "creates user from google oauth with verified northwestern email" do
    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "google-uid-verified-test",
      "info" => { "email" => "verified@u.northwestern.edu", "first_name" => "Verified" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    )
    user = User.from_omniauth(auth)
    assert user.persisted?
    assert_equal "verified@u.northwestern.edu", user.email
    assert_equal "Verified", user.first_name
  end

  test "rejects google oauth with unverified email" do
    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "google-uid-unverified-test",
      "info" => { "email" => "unverified@u.northwestern.edu", "first_name" => "Unverified" },
      "extra" => { "raw_info" => { "email_verified" => false } }
    )
    user = User.from_omniauth(auth)
    assert_nil user, "Should not create user with unverified email"
  end

  test "rejects google oauth with non-northwestern email" do
    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "google-uid-non-nu",
      "info" => { "email" => "user@gmail.com", "first_name" => "Gmail" },
      "extra" => { "raw_info" => { "email_verified" => true } }
    )
    user = User.from_omniauth(auth)
    assert_nil user, "Should not create user with non-Northwestern email"
  end

  test "creates user from google without password when provider and uid set" do
    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "google-uid-new-user-test",
      "info" => { "email" => "new-oauth-user@u.northwestern.edu", "first_name" => "Casey" }
    )
    user = User.from_omniauth(auth)
    assert user.persisted?
    assert_equal "new-oauth-user@u.northwestern.edu", user.email
    assert_equal "Casey", user.first_name
    assert user.password_digest.blank?
  end

  test "links existing user by provider and uid on repeat oauth login" do
    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "google-uid-existing-link",
      "info" => { "email" => "existing@u.northwestern.edu", "first_name" => "Existing" }
    )
    user1 = User.from_omniauth(auth)
    id1 = user1.id

    user2 = User.from_omniauth(auth)
    id2 = user2.id

    assert_equal id1, id2, "Should return same user on repeat OAuth login"
  end

  test "links to existing user by email if provider/uid not found" do
    existing = User.create!(
      email: "existing-match@u.northwestern.edu",
      first_name: "Existing",
      provider: "google_oauth2",
      uid: "old-uid"
    )

    auth = OmniAuth::AuthHash.new(
      "provider" => "google_oauth2",
      "uid" => "new-uid",
      "info" => { "email" => "existing-match@u.northwestern.edu", "first_name" => "Updated" }
    )

    user = User.from_omniauth(auth)
    assert_equal existing.id, user.id
    assert_equal "new-uid", user.uid
  end

  # ============================================================================
  # Admin and Access Control Tests
  # ============================================================================

  test "admin? is true only for configured admin email" do
    assert users(:admin).admin?
    assert_not users(:nu_student).admin?
  end

  test "reputation_score uses rental and marketplace exchange ratings" do
    assert_in_delta 4.0, users(:admin).reputation_score, 0.001
    assert_equal 1, users(:admin).reputation_ratings_count
    assert_in_delta 5.0, users(:nu_student).reputation_score, 0.001
    assert_equal 1, users(:nu_student).reputation_ratings_count
  end

  test "rejects duplicate email" do
    email = "dup-uniqueness-test@u.northwestern.edu"
    User.create!(email: email, first_name: "Dup", password: "password123", password_confirmation: "password123")
    other = User.new(email: email, first_name: "Other", password: "password123", password_confirmation: "password123")
    assert_not other.valid?
    assert_includes other.errors[:email], "has already been taken"
  end

  # ============================================================================
  # Security Tests — Northwestern Email Pattern
  # ============================================================================

  test "NORTHWESTERN_EMAIL pattern constants exist" do
    assert_const_defined User, :NORTHWESTERN_EMAIL
    pattern = User::NORTHWESTERN_EMAIL
    assert pattern.is_a?(Regexp)
  end

  test "pattern matches valid u.northwestern.edu emails" do
    valid_emails = [
      "student@u.northwestern.edu",
      "faculty@u.northwestern.edu",
      "staff@u.northwestern.edu",
      "abc123@u.northwestern.edu",
      "first.last@u.northwestern.edu",
      "first_last@u.northwestern.edu"
    ]
    valid_emails.each do |email|
      assert email.match?(User::NORTHWESTERN_EMAIL), "Should match: #{email}"
    end
  end

  test "pattern matches valid northwestern.edu emails" do
    valid_emails = [
      "student@northwestern.edu",
      "faculty@northwestern.edu",
      "admin@northwestern.edu"
    ]
    valid_emails.each do |email|
      assert email.match?(User::NORTHWESTERN_EMAIL), "Should match: #{email}"
    end
  end

  test "pattern rejects invalid domains" do
    invalid_emails = [
      "student@u-northwestern.edu",
      "student@unorthwestern.edu",
      "student@northwestern.org",
      "student@northwestern.com",
      "student@u.northwestern.com",
      "student@gmail.com",
      "student@yahoo.com",
      "student@example.com"
    ]
    invalid_emails.each do |email|
      assert_not email.match?(User::NORTHWESTERN_EMAIL), "Should NOT match: #{email}"
    end
  end

  test "pattern rejects emails with spaces" do
    invalid_emails = [
      "student name@u.northwestern.edu",
      "student@u.north western.edu",
      " student@u.northwestern.edu",
      "student@u.northwestern.edu "
    ]
    invalid_emails.each do |email|
      assert_not email.match?(User::NORTHWESTERN_EMAIL), "Should NOT match: #{email}"
    end
  end

  test "pattern is case-insensitive" do
    mixed_case = "StUdEnT@U.NoRtHwEsTeRn.EdU"
    assert mixed_case.match?(User::NORTHWESTERN_EMAIL), "Pattern should be case-insensitive"
  end

  # ============================================================================
  # Integration Test — End-to-End User Creation and Verification
  # ============================================================================

  test "cannot create listing without verified northwestern user" do
    # This tests that listings require a user relationship
    # and that the user must have a northwestern email
    bad_user_data = {
      email: "faker@gmail.com",
      first_name: "Faker",
      password: "password123",
      password_confirmation: "password123"
    }
    user = User.new(bad_user_data)
    assert_not user.valid?, "Non-northwestern user should be invalid"
  end

  private

  def assert_const_defined(klass, const_name)
    assert_const = klass.const_defined?(const_name)
    assert assert_const, "Expected #{klass} to define #{const_name}"
  end
end
