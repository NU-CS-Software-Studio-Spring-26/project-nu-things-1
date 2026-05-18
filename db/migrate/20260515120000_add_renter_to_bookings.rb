# frozen_string_literal: true

class AddRenterToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :renter, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
  end
end
