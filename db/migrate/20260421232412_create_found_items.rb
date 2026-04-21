class CreateFoundItems < ActiveRecord::Migration[8.1]
  def change
    create_table :found_items do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :location_found, null: false
      t.date :date_found, null: false
      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :status, null: false, default: "unclaimed"
      t.string :image_url
      t.string :storage_location
      t.string :color
      t.string :brand

      t.timestamps
    end
  end
end
