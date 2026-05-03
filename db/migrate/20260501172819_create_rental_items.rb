class CreateRentalItems < ActiveRecord::Migration[8.1]
  def change
    create_table :rental_items do |t|
      t.string :title
      t.text :description
      t.string :category
      t.decimal :rental_price
      t.string :rental_period
      t.string :condition
      t.string :location
      t.date :available_from
      t.date :available_to
      t.string :image_url
      t.string :owner_name
      t.string :owner_email
      t.string :owner_phone
      t.decimal :deposit_required
      t.string :status

      t.timestamps
    end
  end
end
