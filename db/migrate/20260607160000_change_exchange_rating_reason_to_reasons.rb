# frozen_string_literal: true

class ChangeExchangeRatingReasonToReasons < ActiveRecord::Migration[8.1]
  def up
    add_column :booking_exchange_ratings, :reasons, :json, default: [], null: false
    add_column :marketplace_exchange_ratings, :reasons, :json, default: [], null: false

    execute "UPDATE booking_exchange_ratings SET reasons = json_array(reason)"
    execute "UPDATE marketplace_exchange_ratings SET reasons = json_array(reason)"

    remove_column :booking_exchange_ratings, :reason
    remove_column :marketplace_exchange_ratings, :reason
  end

  def down
    add_column :booking_exchange_ratings, :reason, :string
    add_column :marketplace_exchange_ratings, :reason, :string

    execute "UPDATE booking_exchange_ratings SET reason = json_extract(reasons, '$[0]')"
    execute "UPDATE marketplace_exchange_ratings SET reason = json_extract(reasons, '$[0]')"

    remove_column :booking_exchange_ratings, :reasons
    remove_column :marketplace_exchange_ratings, :reasons

    change_column_null :booking_exchange_ratings, :reason, false
    change_column_null :marketplace_exchange_ratings, :reason, false
  end
end
