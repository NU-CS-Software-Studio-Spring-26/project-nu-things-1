# frozen_string_literal: true

module ProfileAvatars
  extend ActiveSupport::Concern

  AVATARS = {
    "squirrel" => "Squirrel",
    "cat" => "Cat",
    "dog" => "Dog",
    "fish" => "Fish",
    "mouse" => "Mouse"
  }.freeze

  included do
    validates :profile_avatar, inclusion: { in: AVATARS.keys }, allow_blank: true
  end

  def profile_avatar_label
    AVATARS[profile_avatar]
  end
end
