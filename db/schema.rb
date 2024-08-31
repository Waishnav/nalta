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

ActiveRecord::Schema[7.1].define(version: 2024_08_27_212119) do
  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "destinations", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.integer "country_id", null: false
    t.decimal "avg_transportation_cost_per_km", precision: 10, scale: 2
    t.decimal "avg_food_cost_per_meal", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_destinations_on_country_id"
  end

  create_table "place_best_times", force: :cascade do |t|
    t.integer "place_id", null: false
    t.integer "best_time_to_visit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_place_best_times_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.integer "destination_id", null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "name", null: false
    t.decimal "average_time_spent", precision: 4, scale: 2
    t.decimal "min_cost", precision: 10, scale: 2
    t.decimal "max_cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_places_on_destination_id"
  end

  create_table "point_of_interests", force: :cascade do |t|
    t.integer "place_id", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_point_of_interests_on_place_id"
  end

  add_foreign_key "destinations", "countries"
  add_foreign_key "place_best_times", "places"
  add_foreign_key "places", "destinations"
  add_foreign_key "point_of_interests", "places"
end
