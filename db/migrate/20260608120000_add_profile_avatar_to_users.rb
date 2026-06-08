# frozen_string_literal: true

class AddProfileAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :profile_avatar, :string
  end
end
