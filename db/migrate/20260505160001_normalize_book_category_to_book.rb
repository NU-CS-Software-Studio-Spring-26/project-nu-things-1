# frozen_string_literal: true

class NormalizeBookCategoryToBook < ActiveRecord::Migration[8.1]
  def up
    if table_exists?(:marketplace_listings)
      execute "UPDATE marketplace_listings SET category = 'Book' WHERE category = 'Books'"
    end
    if table_exists?(:rental_items)
      execute "UPDATE rental_items SET category = 'Book' WHERE category = 'Books'"
    end
  end
end
