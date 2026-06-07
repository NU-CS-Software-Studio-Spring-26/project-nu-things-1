# frozen_string_literal: true

class CreateMarketplaceTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplace_transactions do |t|
      t.references :conversation, null: false, foreign_key: true, index: { unique: true }
      t.references :marketplace_listing, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.datetime :buyer_marked_complete_at
      t.datetime :seller_marked_complete_at

      t.timestamps
    end
  end
end
