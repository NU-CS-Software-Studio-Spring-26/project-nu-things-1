class MarketplaceListingsController < ApplicationController
  before_action :set_marketplace_listing, only: %i[show edit update destroy]

  def index
    @marketplace_listings = MarketplaceListing.where(status: "active").order(created_at: :desc)
    @marketplace_listings = @marketplace_listings.where(listing_type: params[:listing_type]) if params[:listing_type].present?
    @marketplace_listings = @marketplace_listings.where(category: params[:category]) if params[:category].present?

    @categories = (MarketplaceListing.distinct.pluck(:category).sort + [ "Other" ]).uniq
  end

  def show
  end

  def new
    @marketplace_listing = MarketplaceListing.new
  end

  def edit
  end

  def create
    @marketplace_listing = MarketplaceListing.new(marketplace_listing_params)

    if @marketplace_listing.save
      redirect_to @marketplace_listing, notice: "Listing was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @marketplace_listing.update(marketplace_listing_params)
      redirect_to @marketplace_listing, notice: "Listing was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @marketplace_listing.destroy
    redirect_to marketplace_listings_path, notice: "Listing was successfully removed.", status: :see_other
  end

  private

  def set_marketplace_listing
    @marketplace_listing = MarketplaceListing.find(params.expect(:id))
  end

  def marketplace_listing_params
    params.expect(marketplace_listing: [
      :title,
      :description,
      :category,
      :condition,
      :image_url,
      :location,
      :listing_type,
      :price,
      :contact_name,
      :contact_email,
      :contact_phone,
      :custom_category,
      :status
    ])
  end
end
