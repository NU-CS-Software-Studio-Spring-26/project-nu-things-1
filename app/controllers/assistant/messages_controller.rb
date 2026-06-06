# frozen_string_literal: true

module Assistant
  class MessagesController < ApplicationController
    before_action :require_login

    rate_limit to: 30, within: 1.hour, scope: :assistant_messages,
               by: -> { "assistant/user/#{current_user.id}" }, with: :notify_rate_limit,
               only: :create

    def create
      unless assistant_gemini_configured?
        respond_to do |format|
          format.html { redirect_to assistant_path, alert: "AI assistant is not configured. Set GEMINI_API_KEY." }
          format.turbo_stream { @assistant_error = "AI assistant is not configured. Set GEMINI_API_KEY." }
        end
        return
      end

      body = params[:message].to_s.strip
      if body.blank?
        respond_to do |format|
          format.html { redirect_to assistant_path, alert: "Please enter a message." }
          format.turbo_stream { @assistant_error = "Please enter a message." }
        end
        return
      end

      if defined?(Moderate::Text) && Moderate::Text.bad_words?(body)
        respond_to do |format|
          format.html { redirect_to assistant_path, alert: profanity_blocked_alert }
          format.turbo_stream { @assistant_error = profanity_blocked_alert }
        end
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
      respond_to do |format|
        format.html { redirect_to assistant_path, alert: e.message }
        format.turbo_stream { @assistant_error = e.message }
      end
    end
  end
end
