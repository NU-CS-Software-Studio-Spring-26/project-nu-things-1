# frozen_string_literal: true

class ProfileAvatarsController < ApplicationController
  before_action :require_login

  def update
    if current_user.update(profile_avatar_params)
      redirect_to user_path(current_user), notice: "Profile picture updated."
    else
      redirect_to user_path(current_user), alert: current_user.errors.full_messages.join(", ")
    end
  end

  private

  def profile_avatar_params
    params.expect(user: [ :profile_avatar ])
  end
end
