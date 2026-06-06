# frozen_string_literal: true

require "test_helper"

class AssistantSessionTest < ActiveSupport::TestCase
  include AssistantSession

  setup do
    @user = users(:nu_student)
    @session = {}
    Rails.cache.delete("assistant_chat/v1/user/#{@user.id}")
  end

  teardown do
    Rails.cache.delete("assistant_chat/v1/user/#{@user.id}")
  end

  test "stores chat in cache not session cookie" do
    append_assistant_user_message!("hello")
    append_assistant_bot_message!(reply: "world", listings: [])

    assert_nil @session[:assistant_chat]
    assert_equal 2, assistant_chat_messages.size
    assert Rails.cache.exist?("assistant_chat/v1/user/#{@user.id}")
  end

  test "migrates legacy session chat into cache" do
    @session[:assistant_chat] = [
      { "role" => "user", "body" => "legacy", "at" => Time.current.iso8601, "listings" => [] }
    ]

    messages = assistant_chat_messages
    assert_equal "legacy", messages.first["body"]
    assert_nil @session[:assistant_chat]
  end

  private

  attr_reader :session

  def current_user
    @user
  end
end
