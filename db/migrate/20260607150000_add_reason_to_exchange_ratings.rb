# frozen_string_literal: true

class AddReasonToExchangeRatings < ActiveRecord::Migration[8.1]
  def change
    add_column :booking_exchange_ratings, :reason, :string, null: false, default: "communication"
    add_column :marketplace_exchange_ratings, :reason, :string, null: false, default: "communication"

    change_column_default :booking_exchange_ratings, :reason, from: "communication", to: nil
    change_column_default :marketplace_exchange_ratings, :reason, from: "communication", to: nil
  end
end
