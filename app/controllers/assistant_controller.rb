# frozen_string_literal: true

class AssistantController < ApplicationController
  before_action :require_login

  def show
    @messages = assistant_chat_messages
  end

  def clear
    clear_assistant_chat!

    respond_to do |format|
      format.html { redirect_to assistant_path, notice: "Chat cleared." }
      format.turbo_stream
    end
  end
end
