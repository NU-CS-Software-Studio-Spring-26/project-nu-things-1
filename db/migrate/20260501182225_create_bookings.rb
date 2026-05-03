class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :rental_item, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, default: "pending", null: false
      t.text :notes

      t.timestamps
    end

    add_index :bookings, [ :rental_item_id, :start_date, :end_date ]
  end
end
