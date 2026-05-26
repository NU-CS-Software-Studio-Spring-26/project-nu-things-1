class CreateMarketplaceListingReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplace_listing_reviews do |t|
      t.references :marketplace_listing, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.string :reviewer_name

      t.timestamps
    end

    add_index :marketplace_listing_reviews,
              [ :marketplace_listing_id, :user_id ],
              unique: true,
              where: "user_id IS NOT NULL"
  end
end
