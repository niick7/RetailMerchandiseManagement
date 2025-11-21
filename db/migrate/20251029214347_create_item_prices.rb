class CreateItemPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :item_prices do |t|
      t.references :item, null: false, foreign_key: true
      t.decimal :price
      t.datetime :effective_date
      t.datetime :end_date
      t.boolean :primary, default: false

      t.timestamps
    end
  end
end
