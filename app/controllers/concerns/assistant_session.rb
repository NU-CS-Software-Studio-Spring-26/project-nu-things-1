# frozen_string_literal: true

module AssistantSession
  extend ActiveSupport::Concern

  MAX_ASSISTANT_MESSAGES = 20
  CHAT_CACHE_TTL = 24.hours

  included do
    helper_method :assistant_chat_messages, :assistant_gemini_configured? if respond_to?(:helper_method)
  end

  def assistant_chat_messages
    return [] unless current_user

    migrate_legacy_session_chat!
    Rails.cache.read(assistant_chat_cache_key) || []
  end

  def assistant_gemini_configured?
    Rails.application.config.x.gemini_api_key.present?
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
    messages = assistant_chat_messages.dup
    entry = assistant_message_entry("user", body)
    messages << entry
    trim_assistant_chat!(messages)
    write_assistant_chat!(messages)
    entry
  end

  def append_assistant_bot_message!(reply:, listings:)
    messages = assistant_chat_messages.dup
    entry = assistant_message_entry("assistant", reply, listings: listings)
    messages << entry
    trim_assistant_chat!(messages)
    write_assistant_chat!(messages)
    entry
  end

  def remove_last_assistant_user_message!
    messages = assistant_chat_messages
    return if messages.blank? || messages.last["role"] != "user"

    write_assistant_chat!(messages[0...-1])
  end

  def clear_assistant_chat!
    session.delete(:assistant_chat)
    Rails.cache.delete(assistant_chat_cache_key) if current_user
  end

  private

  def assistant_chat_cache_key
    "assistant_chat/v1/user/#{current_user.id}"
  end

  def migrate_legacy_session_chat!
    legacy = session[:assistant_chat]
    return if legacy.blank?

    write_assistant_chat!(legacy)
    session.delete(:assistant_chat)
  end

  def write_assistant_chat!(messages)
    Rails.cache.write(assistant_chat_cache_key, messages, expires_in: CHAT_CACHE_TTL)
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
