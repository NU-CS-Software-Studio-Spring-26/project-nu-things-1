class FoundItemsController < ApplicationController
  before_action :require_admin, only: %i[edit update destroy]
  before_action :set_found_item, only: %i[show edit update destroy claim]

  def index
    @found_items = FoundItem.with_attached_photo.order(date_found: :desc, created_at: :desc)
    @categories = filter_category_options(FoundItem)
    @found_items = filter_where_in(@found_items, :category, params[:category], @categories)
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

  def claim
    if @found_item.status != "unclaimed"
      redirect_to @found_item, alert: "This item is not available to claim."
      return
    end

    @found_item.update!(status: "claimed", claimed_by_user_id: current_user.id)
    redirect_to @found_item, notice: "You marked this item as claimed."
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
    @found_item = FoundItem.with_attached_photo.find(params.expect(:id))
  end

  def found_item_params
    params.expect(found_item: [ :title, :description, :category, :location_found, :date_found,
                                  :contact_name, :contact_email, :status, :image_url, :photo, :storage_location, :color, :brand ])
  end
end
