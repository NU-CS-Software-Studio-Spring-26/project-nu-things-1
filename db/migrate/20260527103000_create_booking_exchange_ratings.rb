# frozen_string_literal: true

class CreateBookingExchangeRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_exchange_ratings do |t|
      t.references :booking, null: false, foreign_key: true

      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :ratee, null: false, foreign_key: { to_table: :users }

      t.integer :rating, null: false
      t.text :body

      t.timestamps
    end

    add_index :booking_exchange_ratings,
              [ :booking_id, :rater_id, :ratee_id ],
              unique: true,
              name: "index_booking_exchange_ratings_on_booking_and_rater_and_ratee"
  end
end
