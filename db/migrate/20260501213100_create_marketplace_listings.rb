class CreateMarketplaceListings < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplace_listings do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :condition
      t.string :image_url
      t.string :location, null: false

      t.string :listing_type, null: false
      t.decimal :price

      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :contact_phone

      t.string :status, null: false, default: "active"

      t.timestamps
    end
  end
end
