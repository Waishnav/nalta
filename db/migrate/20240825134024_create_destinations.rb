class CreateDestinations < ActiveRecord::Migration[7.1]
  def change
    create_table :destinations do |t|
      t.string :name, default: "", null: false
      t.text :description, default: "", null: false
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :country
      t.decimal :avg_transportation_cost_per_km, precision: 10, scale: 2
      t.decimal :avg_food_cost_per_meal, precision: 10, scale: 2

      t.timestamps
    end
  end
end
