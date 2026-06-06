# frozen_string_literal: true

module AssistantSession
  extend ActiveSupport::Concern

  MAX_ASSISTANT_MESSAGES = 20

  private

  def assistant_chat_messages
    session[:assistant_chat] ||= []
  end

  def assistant_history_for_prompt
    assistant_chat_messages.map do |entry|
      {
        "role" => entry["role"],
        "body" => entry["body"]
      }
    end
  end

  def append_assistant_user_message!(body)
    messages = assistant_chat_messages
    messages << assistant_message_entry("user", body)
    trim_assistant_chat!(messages)
    session[:assistant_chat] = messages
  end

  def append_assistant_bot_message!(reply:, listings:)
    messages = assistant_chat_messages
    messages << assistant_message_entry("assistant", reply, listings: listings)
    trim_assistant_chat!(messages)
    session[:assistant_chat] = messages
  end

  def clear_assistant_chat!
    session.delete(:assistant_chat)
  end

  def trim_assistant_chat!(messages)
    messages.shift while messages.size > MAX_ASSISTANT_MESSAGES
  end

  def assistant_message_entry(role, body, listings: [])
    {
      "role" => role,
      "body" => body,
      "at" => Time.current.iso8601,
      "listings" => serialize_listings(listings)
    }
  end

  def serialize_listings(listings)
    Array(listings).map do |listing|
      {
        "key" => listing.key,
        "type" => listing.type,
        "id" => listing.id,
        "title" => listing.title,
        "board_label" => listing.board_label,
        "reason" => listing.reason,
        "path" => listing.path,
        "category" => listing.category,
        "location" => listing.location
      }
    end
  end
end
