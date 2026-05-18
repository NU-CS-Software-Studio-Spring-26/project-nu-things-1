# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about privacy and terms pages render" do
    get about_url
    assert_response :success
    assert_match(/About LoFoNU/, @response.body)

    get privacy_url
    assert_response :success
    assert_match(/What we collect/, @response.body)

    get terms_url
    assert_response :success
    assert_match(/No affiliation/, @response.body)
  end

  test "home includes About Privacy Terms links" do
    get root_url
    assert_response :success
    assert_select "a[href=?]", about_path, text: "About"
    assert_select "a[href=?]", privacy_path, text: "Privacy"
    assert_select "a[href=?]", terms_path, text: "Terms"
  end

  test "GitHub link appears when source code URL is configured" do
    prev = Rails.application.config.x.source_code_url
    Rails.application.config.x.source_code_url = "https://github.com/example/repo"
    get root_url
    assert_response :success
    assert_select "a[href=?]", "https://github.com/example/repo", text: "GitHub"
  ensure
    Rails.application.config.x.source_code_url = prev
  end
end
