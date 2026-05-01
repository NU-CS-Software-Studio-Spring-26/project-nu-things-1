class AddCustomCategoryToMarketplaceListings < ActiveRecord::Migration[8.1]
  def change
    add_column :marketplace_listings, :custom_category, :string
  end
end

