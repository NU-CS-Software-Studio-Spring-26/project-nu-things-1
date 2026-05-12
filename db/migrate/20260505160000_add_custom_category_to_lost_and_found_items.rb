# frozen_string_literal: true

class AddCustomCategoryToLostAndFoundItems < ActiveRecord::Migration[8.1]
  def change
    add_column :lost_items, :custom_category, :string
    add_column :found_items, :custom_category, :string
  end
end
