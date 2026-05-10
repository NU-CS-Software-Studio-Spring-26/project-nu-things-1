class AddUserToListings < ActiveRecord::Migration[8.1]
  def change
    add_reference :lost_items, :user, foreign_key: true, null: true
    add_reference :found_items, :user, foreign_key: true, null: true
    add_reference :marketplace_listings, :user, foreign_key: true, null: true
    add_reference :rental_items, :user, foreign_key: true, null: true
  end
end
