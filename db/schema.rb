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
    t.string "title", null: false
    t.text "description", null: false
    t.string "category", null: false
    t.string "condition"
    t.string "image_url"
    t.string "location", null: false
    t.string "custom_category"
    t.string "listing_type", null: false
    t.decimal "price"
    t.string "contact_name", null: false
    t.string "contact_email", null: false
    t.string "contact_phone"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
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
end
