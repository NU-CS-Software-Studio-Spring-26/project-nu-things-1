class AddRenterAndExchangeToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :user, foreign_key: true
    add_column :bookings, :owner_marked_given_at, :datetime
    add_column :bookings, :renter_marked_received_at, :datetime
  end
end
