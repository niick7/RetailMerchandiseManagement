class Admin::ItemsController < Admin::AdminController
  before_action :find_item, only: [:show, :edit, :update]
  def index
    @keyword = params[:q].to_s.strip
    @pagy, @items = pagy(Item.search(@keyword).order_created_at)
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.items.new(item_params)

    if @item.save
      redirect_to admin_item_path(@item), notice: "Item created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    extend_params = item_params.merge(user_id: current_user.id)
    if @item.update(item_params)
      redirect_to admin_item_path(@item), notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_item
    @item = Item.find_by_id(params[:id])
  end

  def item_params
    params.require(:item).permit(:sku, :active)
  end
end
