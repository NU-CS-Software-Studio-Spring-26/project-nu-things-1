class RentalItemsController < ApplicationController
  before_action :require_admin, only: %i[edit update destroy]
  before_action :set_rental_item, only: %i[ show edit update destroy ]

  def index
    @rental_items = RentalItem.where(status: "available").order(created_at: :desc)
    @rental_items = @rental_items.where(category: params[:category]) if params[:category].present?
    @categories = (RentalItem.distinct.pluck(:category).sort + [ "Other" ]).uniq
  end

  def show
  end

  def new
    @rental_item = RentalItem.new
  end

  def edit
  end

  def create
    @rental_item = RentalItem.new(rental_item_params)

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
    @rental_item = RentalItem.find(params.expect(:id))
  end

  def rental_item_params
    params.expect(rental_item: [ :title, :description, :category, :rental_price, :rental_period,
                                  :condition, :location, :available_from, :available_to, :image_url,
                                  :owner_name, :owner_email, :owner_phone, :deposit_required, :status ])
  end
end
