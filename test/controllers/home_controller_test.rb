require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
  end

  test "guest post links on home point at sign in with return_to" do
    get root_url
    assert_response :success
    assert_match(%r{/session/new\?[^\"']*return_to=}, @response.body)
  end
end
