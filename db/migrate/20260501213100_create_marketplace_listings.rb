class CreateMarketplaceListings < ActiveRecord::Migration[8.1]
  def change
    create_table :marketplace_listings do |t|
      t.string :title
      t.text :description
      t.string :category
      t.string :condition
      t.string :image_url
      t.string :location

      t.string :listing_type
      t.decimal :price

      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone

      t.string :status

      t.timestamps
    end
  end
end
