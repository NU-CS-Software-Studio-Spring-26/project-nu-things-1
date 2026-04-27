class LostItemsController < ApplicationController
  before_action :set_lost_item, only: %i[show edit update destroy]

  def index
    @lost_items = LostItem.order(date_lost: :desc, created_at: :desc)
    @lost_items = @lost_items.where(category: params[:category]) if params[:category].present?
    @categories = LostItem.distinct.pluck(:category).sort + ["Other"]
  end

  def show
  end

  def new
    @lost_item = LostItem.new
  end

  def edit
  end

  def create
    @lost_item = LostItem.new(lost_item_params)

    if @lost_item.save
      redirect_to @lost_item, notice: "Lost item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lost_item.update(lost_item_params)
      redirect_to @lost_item, notice: "Lost item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lost_item.destroy
    redirect_to lost_items_path, notice: "Lost item was successfully removed.", status: :see_other
  end

  private

  def set_lost_item
    @lost_item = LostItem.find(params.expect(:id))
  end

  def lost_item_params
    params.expect(lost_item: [ :title, :description, :category, :location_lost, :date_lost,
                               :contact_name, :contact_email, :status, :image_url, :reward, :color, :brand ])
  end
end
