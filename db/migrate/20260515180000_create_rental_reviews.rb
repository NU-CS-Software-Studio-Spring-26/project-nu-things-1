class CreateRentalReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :rental_reviews do |t|
      t.references :rental_item, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.string :reviewer_name

      t.timestamps
    end

    add_index :rental_reviews, [ :rental_item_id, :user_id ], unique: true, where: "user_id IS NOT NULL"
  end
end
