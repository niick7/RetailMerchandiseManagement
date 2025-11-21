class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :sku
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
