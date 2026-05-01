require_relative "application_system_test_case"

class HomePageSystemTest < ApplicationSystemTestCase
  test "home page loads with title and navigation" do
    visit root_url

    assert_selector "h1", text: "Northwestern Lost and Found Board"
    assert_selector "a", text: "Lost Items"
    assert_selector "a", text: "Found Items"
  end
end
