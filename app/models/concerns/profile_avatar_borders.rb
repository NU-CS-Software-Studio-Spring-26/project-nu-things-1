# frozen_string_literal: true

module ProfileAvatarBorders
  extend ActiveSupport::Concern

  BORDER_STYLES = {
    "default" => "Default",
    "regular" => "Regular",
    "dashed" => "Dashed"
  }.freeze

  BORDER_COLORS = {
    "default" => "Default",
    "pink" => "Pink",
    "blue" => "Blue",
    "purple" => "Purple"
  }.freeze

  included do
    validates :profile_avatar_border_style, inclusion: { in: BORDER_STYLES.keys }, allow_blank: true
    validates :profile_avatar_border_color, inclusion: { in: BORDER_COLORS.keys }, allow_blank: true
    before_validation :normalize_profile_avatar_border_settings
  end

  def profile_avatar_border_style_label
    BORDER_STYLES[profile_avatar_border_style.presence || "default"]
  end

  def profile_avatar_border_color_label
    BORDER_COLORS[profile_avatar_border_color.presence || "default"]
  end

  def profile_avatar_border_default?
    profile_avatar_border_style.blank? || profile_avatar_border_style == "default"
  end

  private

  def normalize_profile_avatar_border_settings
    if profile_avatar_border_default?
      self.profile_avatar_border_color = nil
    elsif profile_avatar_border_color.blank?
      self.profile_avatar_border_color = "purple"
    end
  end
end
