# frozen_string_literal: true

class AddReturnFlowAndPhaseToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :renter_marked_returned_at, :datetime
    add_column :bookings, :owner_marked_return_received_at, :datetime

    add_column :booking_exchange_ratings, :interaction_phase, :string, null: false, default: "pickup"

    remove_index :booking_exchange_ratings, name: "index_booking_exchange_ratings_on_booking_and_rater_and_ratee"
    add_index :booking_exchange_ratings,
              [ :booking_id, :rater_id, :ratee_id, :interaction_phase ],
              unique: true,
              name: "index_booking_exchange_ratings_on_booking_rater_ratee_phase"
  end
end
