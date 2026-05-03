class AddClaimedByUserToFoundItems < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:found_items, :claimed_by_user_id)
      add_reference :found_items, :claimed_by_user, foreign_key: { to_table: :users }
    end
  end
end
