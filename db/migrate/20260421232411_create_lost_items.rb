class CreateLostItems < ActiveRecord::Migration[8.1]
  def change
    create_table :lost_items do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :location_lost, null: false
      t.date :date_lost, null: false
      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :status, null: false, default: "open"
      t.string :image_url
      t.string :reward
      t.string :color
      t.string :brand

      t.timestamps
    end
  end
end
