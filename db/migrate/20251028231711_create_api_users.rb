class CreateApiUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :api_users do |t|
      t.references :user, null: false, foreign_key: true
      t.string :api_token
      t.datetime :api_token_expired_at
      t.integer :api_quota, default: 0

      t.timestamps
    end
  end
end
