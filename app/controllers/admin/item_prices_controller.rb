class Admin::ItemPricesController < Admin::AdminController
  before_action :set_item
  before_action :set_item_price, only: [:edit, :update, :destroy]

  def new
    @item_price = @item.item_prices.new(
      effective_date: Time.current.beginning_of_day,
      end_date: 1.year.from_now.end_of_day
    )
  end

  def create
    @item_price = @item.item_prices.new(item_price_params)

    if @item_price.save
      redirect_to [:admin, @item], notice: "Item price was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item_price.update(item_price_params)
      redirect_to [:admin, @item], notice: "Item price was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item_price.destroy
    redirect_to [:admin, @item], notice: "Item price was successfully deleted."
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_item_price
    @item_price = @item.item_prices.find(params[:id])
  end

  def item_price_params
    params.require(:item_price).permit(
      :price,
      :effective_date,
      :end_date,
      :primary
    )
  end
end