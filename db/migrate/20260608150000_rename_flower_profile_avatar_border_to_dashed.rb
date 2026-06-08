# frozen_string_literal: true

class RenameFlowerProfileAvatarBorderToDashed < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE users SET profile_avatar_border_style = 'dashed' WHERE profile_avatar_border_style = 'flower'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE users SET profile_avatar_border_style = 'flower' WHERE profile_avatar_border_style = 'dashed'
    SQL
  end
end
