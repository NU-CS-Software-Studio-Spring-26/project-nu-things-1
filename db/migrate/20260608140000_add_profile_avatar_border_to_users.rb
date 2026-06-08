# frozen_string_literal: true

class AddProfileAvatarBorderToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :profile_avatar_border_style, :string
    add_column :users, :profile_avatar_border_color, :string
  end
end
