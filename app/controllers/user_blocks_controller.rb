# frozen_string_literal: true

class UserBlocksController < ApplicationController
  before_action :require_login
  before_action :set_blocked_user, only: %i[create destroy]

  def create
    if @blocked_user == current_user
      redirect_back fallback_location: conversations_path, alert: "You cannot block yourself."
      return
    end

    current_user.block!(@blocked_user)
    redirect_back fallback_location: conversations_path,
                  notice: "#{helpers.display_user_name(@blocked_user)} has been blocked. They can no longer message you or see your listings."
  end

  def destroy
    current_user.unblock!(@blocked_user)
    redirect_back fallback_location: user_path(current_user),
                  notice: "#{helpers.display_user_name(@blocked_user)} has been unblocked."
  end

  private

  def set_blocked_user
    @blocked_user = User.find(params.expect(:user_id))
  end
end
