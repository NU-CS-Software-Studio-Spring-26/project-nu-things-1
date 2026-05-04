require_relative "application_system_test_case"

class HomePageSystemTest < ApplicationSystemTestCase
  test "home page loads with title and navigation" do
    visit root_url

    assert_selector "h1", text: "NU Things"
    assert_selector "a", text: "Lost Items"
    assert_selector "a", text: "Found Items"
    assert_selector "a", text: "Post lost item"
    assert_selector "a", text: "Post found item"
  end

  test "guest post buttons go to sign in with return_to" do
    visit root_url

    within(".nu-home-actions") do
      link = find("a", text: "Post lost item", match: :first)
      assert_match(%r{/session/new}, link[:href])
      assert_match(/return_to=/, link[:href])
    end
  end
end
