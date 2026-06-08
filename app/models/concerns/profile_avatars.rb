# frozen_string_literal: true

module ProfileAvatars
  extend ActiveSupport::Concern

  AVATARS = {
    "initial" => "Initial",
    "squirrel" => "Squirrel",
    "cat" => "Cat",
    "dog" => "Dog",
    "fish" => "Fish",
    "mouse" => "Mouse"
  }.freeze

  ANIMAL_AVATARS = (AVATARS.keys - [ "initial" ]).freeze

  included do
    validates :profile_avatar, inclusion: { in: AVATARS.keys }, allow_blank: true
  end

  def profile_avatar_label
    AVATARS[profile_avatar]
  end

  def profile_avatar_initial?
    profile_avatar.blank? || profile_avatar == "initial"
  end
end
