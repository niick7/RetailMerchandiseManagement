# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_21_215556) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "api_token"
    t.datetime "api_token_expired_at"
    t.integer "api_quota", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_users_on_user_id"
  end

  create_table "import_batches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "import_type", null: false
    t.string "original_filename"
    t.string "status", default: "queued", null: false
    t.integer "total_rows", default: 0
    t.integer "success_count", default: 0
    t.integer "error_count", default: 0
    t.string "failed_file_path"
    t.text "error_messages"
    t.string "sidekiq_jid"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_type"], name: "index_import_batches_on_import_type"
    t.index ["status"], name: "index_import_batches_on_status"
    t.index ["user_id"], name: "index_import_batches_on_user_id"
  end

  create_table "item_prices", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.decimal "price"
    t.datetime "effective_date"
    t.datetime "end_date"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_prices_on_item_id"
  end

  create_table "item_upcs", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "upc_code"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_upcs_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "sku"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_items_on_sku"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "is_admin", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "api_users", "users"
  add_foreign_key "import_batches", "users"
  add_foreign_key "item_prices", "items"
  add_foreign_key "item_upcs", "items"
  add_foreign_key "items", "users"
end
