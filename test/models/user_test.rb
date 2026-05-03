require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires northwestern email" do
    user = User.new(email: "a@gmail.com", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "accepts u.northwestern.edu" do
    user = User.new(email: "x@u.northwestern.edu", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "accepts northwestern.edu" do
    user = User.new(email: "x@northwestern.edu", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "rejects duplicate email" do
    email = "dup-uniqueness-test@u.northwestern.edu"
    User.create!(email: email, password: "password123", password_confirmation: "password123")
    other = User.new(email: email, password: "password123", password_confirmation: "password123")
    assert_not other.valid?
    assert_includes other.errors[:email], "has already been taken"
  end
end
