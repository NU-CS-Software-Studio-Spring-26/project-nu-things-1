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

ActiveRecord::Schema[8.1].define(version: 2026_05_01_213100) do
  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.text "notes"
    t.integer "rental_item_id", null: false
    t.date "start_date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["rental_item_id", "start_date", "end_date"], name: "index_bookings_on_rental_item_id_and_start_date_and_end_date"
    t.index ["rental_item_id"], name: "index_bookings_on_rental_item_id"
  end

  create_table "claims", force: :cascade do |t|
    t.bigint "claimable_id", null: false
    t.string "claimable_type", null: false
    t.datetime "created_at", null: false
    t.string "status", default: "requested", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["claimable_type", "claimable_id"], name: "index_claims_on_claimable_type_and_claimable_id"
    t.index ["user_id", "claimable_type", "claimable_id"], name: "index_claims_on_user_and_claimable", unique: true
    t.index ["user_id"], name: "index_claims_on_user_id"
  end

  create_table "found_items", force: :cascade do |t|
    t.string "brand"
    t.string "category", null: false
    t.string "color"
    t.string "contact_email", null: false
    t.string "contact_name", null: false
    t.datetime "created_at", null: false
    t.date "date_found", null: false
    t.text "description", null: false
    t.string "image_url"
    t.string "location_found", null: false
    t.string "status", default: "unclaimed", null: false
    t.string "storage_location"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "login_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.integer "user_id", null: false
    t.index ["expires_at"], name: "index_login_tokens_on_expires_at"
    t.index ["user_id"], name: "index_login_tokens_on_user_id"
  end

  create_table "lost_items", force: :cascade do |t|
    t.string "brand"
    t.string "category", null: false
    t.string "color"
    t.string "contact_email", null: false
    t.string "contact_name", null: false
    t.datetime "created_at", null: false
    t.date "date_lost", null: false
    t.text "description", null: false
    t.string "image_url"
    t.string "location_lost", null: false
    t.string "reward"
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "marketplace_listings", force: :cascade do |t|
    t.string "category", null: false
    t.string "condition"
    t.string "contact_email", null: false
    t.string "contact_name", null: false
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.string "custom_category"
    t.text "description", null: false
    t.string "image_url"
    t.string "listing_type", null: false
    t.string "location", null: false
    t.decimal "price"
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rental_items", force: :cascade do |t|
    t.date "available_from"
    t.date "available_to"
    t.string "category"
    t.string "condition"
    t.datetime "created_at", null: false
    t.decimal "deposit_required"
    t.text "description"
    t.string "image_url"
    t.string "location"
    t.string "owner_email"
    t.string "owner_name"
    t.string "owner_phone"
    t.string "rental_period"
    t.decimal "rental_price"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index "lower(email)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "bookings", "rental_items"
  add_foreign_key "claims", "users"
  add_foreign_key "login_tokens", "users"
end
