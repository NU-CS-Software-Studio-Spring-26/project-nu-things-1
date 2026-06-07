# frozen_string_literal: true

class CreateMarketplaceExchangeRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplace_exchange_ratings do |t|
      t.references :marketplace_transaction, null: false, foreign_key: true
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :ratee, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :body

      t.timestamps
    end

    add_index :marketplace_exchange_ratings,
              %i[marketplace_transaction_id rater_id ratee_id],
              unique: true,
              name: "index_marketplace_exchange_ratings_on_transaction_and_rater"
  end
end
