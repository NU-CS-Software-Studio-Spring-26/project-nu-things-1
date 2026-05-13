require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires northwestern email" do
    user = User.new(email: "a@gmail.com", first_name: "Pat", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "accepts u.northwestern.edu" do
    user = User.new(email: "x@u.northwestern.edu", first_name: "X", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "accepts northwestern.edu" do
    user = User.new(email: "x@northwestern.edu", first_name: "X", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "admin? is true only for configured admin email" do
    assert users(:admin).admin?
    assert_not users(:nu_student).admin?
  end

  test "rejects duplicate email" do
    email = "dup-uniqueness-test@u.northwestern.edu"
    User.create!(email: email, first_name: "Dup", password: "password123", password_confirmation: "password123")
    other = User.new(email: email, first_name: "Other", password: "password123", password_confirmation: "password123")
    assert_not other.valid?
    assert_includes other.errors[:email], "has already been taken"
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
end
