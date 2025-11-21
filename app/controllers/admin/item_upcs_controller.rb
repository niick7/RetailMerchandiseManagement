class Admin::ItemUpcsController < Admin::AdminController
  before_action :set_item
  before_action :set_item_upc, only: [:edit, :update, :destroy]

  def new
    @item_upc = @item.item_upcs.new
  end

  def create
    @item_upc = @item.item_upcs.new(item_upc_params)

    if @item_upc.save
      redirect_to admin_item_path(@item), notice: "UPC was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item_upc.update(item_upc_params)
      redirect_to admin_item_path(@item), notice: "UPC was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item_upc.destroy
    redirect_to admin_item_path(@item), notice: "UPC was deleted."
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_item_upc
    @item_upc = @item.item_upcs.find(params[:id])
  end

  def item_upc_params
    params.require(:item_upc).permit(:upc_code, :primary)
  end
end