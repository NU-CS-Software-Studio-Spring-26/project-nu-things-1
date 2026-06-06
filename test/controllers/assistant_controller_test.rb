# frozen_string_literal: true

require "test_helper"

class AssistantControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:nu_student)
    @original_key = Rails.application.config.x.gemini_api_key
    Rails.application.config.x.gemini_api_key = "test-key"
  end

  teardown do
    Rails.application.config.x.gemini_api_key = @original_key
  end

  test "redirects guests to sign in" do
    get assistant_url
    assert_redirected_to new_session_path
  end

  test "shows assistant page when signed in" do
    sign_in_as @user
    get assistant_url
    assert_response :success
    assert_select "h2", /AI Finder/i
  end

  test "clear removes chat history" do
    sign_in_as @user

    result = Assistant::Chat::Result.new(reply: "Stubbed reply.", listings: [])
    original = Assistant::Chat.method(:process!)
    Assistant::Chat.define_singleton_method(:process!) { |**| result }

    post assistant_messages_url, params: { message: "hello world" }
    delete clear_assistant_url
    follow_redirect!

    assert_response :success
    assert_no_match(/hello world/i, response.body)
    assert_no_match(/Stubbed reply/i, response.body)
  ensure
    Assistant::Chat.define_singleton_method(:process!, original)
  end
end
