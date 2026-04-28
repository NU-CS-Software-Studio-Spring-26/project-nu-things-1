class CreateClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :claims do |t|
      t.references :user, null: false, foreign_key: true
      t.string :claimable_type, null: false
      t.bigint :claimable_id, null: false
      t.string :status, null: false, default: "requested"

      t.timestamps
    end

    add_index :claims, %i[claimable_type claimable_id]
    add_index :claims, %i[user_id claimable_type claimable_id], unique: true, name: "index_claims_on_user_and_claimable"
  end
end

