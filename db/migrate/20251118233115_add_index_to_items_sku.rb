class AddIndexToItemsSku < ActiveRecord::Migration[8.0]
  def change
    add_index :items, :sku
  end
end
