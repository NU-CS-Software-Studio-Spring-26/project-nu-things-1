class FoundItemsController < ApplicationController
  before_action :set_found_item, only: %i[show edit update destroy]

  def index
    @found_items = FoundItem.order(date_found: :desc, created_at: :desc)
    @found_items = @found_items.where(category: params[:category]) if params[:category].present?
    @categories = FoundItem.distinct.pluck(:category).sort + [ "Other" ]
  end

  def show
  end

  def new
    @found_item = FoundItem.new
  end

  def edit
  end

  def create
    @found_item = FoundItem.new(found_item_params)

    if @found_item.save
      redirect_to @found_item, notice: "Found item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @found_item.update(found_item_params)
      redirect_to @found_item, notice: "Found item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @found_item.destroy
    redirect_to found_items_path, notice: "Found item was successfully removed.", status: :see_other
  end

  private

  def set_found_item
    @found_item = FoundItem.find(params.expect(:id))
  end

  def found_item_params
    params.expect(found_item: [ :title, :description, :category, :location_found, :date_found,
                                  :contact_name, :contact_email, :status, :image_url, :storage_location, :color, :brand ])
  end
end
