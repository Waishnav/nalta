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

ActiveRecord::Schema[7.1].define(version: 2024_08_25_140014) do
  create_table "activities", force: :cascade do |t|
    t.integer "place_id"
    t.string "name"
    t.text "description"
    t.integer "average_time_spent"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.integer "category"
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_activities_on_place_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "description", default: "", null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "country"
    t.decimal "avg_transportation_cost_per_km", precision: 10, scale: 2
    t.decimal "avg_food_cost_per_meal", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "places", force: :cascade do |t|
    t.integer "destination_id"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "name"
    t.text "description"
    t.integer "category"
    t.integer "average_time_spent"
    t.time "opening_hours"
    t.time "closing_hours"
    t.decimal "min_cost", precision: 10, scale: 2
    t.decimal "max_cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_places_on_destination_id"
  end

  add_foreign_key "activities", "places"
  add_foreign_key "places", "destinations"
end
