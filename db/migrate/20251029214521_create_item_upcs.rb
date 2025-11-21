class CreateItemUpcs < ActiveRecord::Migration[8.0]
  def change
    create_table :item_upcs do |t|
      t.references :item, null: false, foreign_key: true
      t.string :upc_code
      t.boolean :primary, default: false

      t.timestamps
    end
  end
end
