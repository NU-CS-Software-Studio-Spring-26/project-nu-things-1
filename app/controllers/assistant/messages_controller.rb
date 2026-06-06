# frozen_string_literal: true

module Assistant
  class MessagesController < ApplicationController
    before_action :require_login

    rate_limit to: 30, within: 1.hour, scope: :assistant_messages,
               by: -> { "assistant/user/#{current_user.id}" }, with: :notify_rate_limit,
               only: :create

    def create
      unless assistant_gemini_configured?
        render_assistant_error("AI assistant is not configured. Set GEMINI_API_KEY.")
        return
      end

      body = params[:message].to_s.strip
      if body.blank?
        render_assistant_error("Please enter a message.")
        return
      end

      if defined?(Moderate::Text) && Moderate::Text.bad_words?(body)
        render_assistant_error(profanity_blocked_alert)
        return
      end

      @user_message = append_assistant_user_message!(body)

      history = assistant_history_for_prompt[0...-1]
      result = Assistant::Chat.process!(message: body, history: history)
      @bot_message = append_assistant_bot_message!(reply: result.reply, listings: result.listings)

      respond_to do |format|
        format.html { redirect_to assistant_path }
        format.turbo_stream
      end
    rescue Assistant::Chat::Error, GeminiClient::Error => e
      remove_last_assistant_user_message!
      render_assistant_error(e.message)
    rescue StandardError => e
      remove_last_assistant_user_message!
      Rails.logger.error("[Assistant::MessagesController] #{e.class}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
      render_assistant_error("Something went wrong. Please try again in a moment.")
    end

    private

    def render_assistant_error(message)
      @assistant_error = message
      respond_to do |format|
        format.html { redirect_to assistant_path, alert: message }
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end
end
