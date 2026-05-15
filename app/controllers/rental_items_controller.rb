class RentalItemsController < ApplicationController
  before_action :set_rental_item, only: %i[show edit update destroy]
  before_action -> { require_owner_or_admin(@rental_item) }, only: %i[edit update]
  before_action :require_admin, only: %i[destroy]

  def index
    @rental_items = RentalItem.with_attached_photo
      .includes(:rental_reviews)
      .where(status: "available")
      .order(created_at: :desc)
    @categories = filter_category_options(RentalItem)
    @rental_items = filter_where_in(@rental_items, :category, params[:category], @categories)
  end

  def show
  end

  def new
    @rental_item = RentalItem.new
    apply_saved_identity_to_new_listing(@rental_item)
  end

  def edit
  end

  def create
    @rental_item = RentalItem.new(rental_item_params)
    @rental_item.user = current_user
    apply_saved_identity_to_new_listing(@rental_item)

    if @rental_item.save
      redirect_to @rental_item, notice: "Rental item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rental_item.update(rental_item_params)
      redirect_to @rental_item, notice: "Rental item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rental_item.destroy
    redirect_to rental_items_path, notice: "Rental item was successfully removed.", status: :see_other
  end

  private

  def set_rental_item
    @rental_item = RentalItem.with_attached_photo.includes(:rental_reviews, :bookings).find(params.expect(:id))
  end

  def rental_item_params
    params.expect(rental_item: [ :title, :description, :category, :rental_price, :rental_period,
                                  :condition, :location, :available_from, :available_to, :image_url, :photo,
                                  :owner_name, :owner_email, :owner_phone, :deposit_required, :status ])
  end
end
