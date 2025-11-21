class CreateImportBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :import_batches do |t|
      t.references :user, null: false, foreign_key: true

      t.string :import_type, null: false
      t.string :original_filename
      t.string :status, null: false, default: "queued"

      t.integer :total_rows, default: 0
      t.integer :success_count, default: 0
      t.integer :error_count, default: 0

      t.string :failed_file_path
      t.text   :error_messages

      t.string :sidekiq_jid

      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :import_batches, :import_type
    add_index :import_batches, :status
  end
end
