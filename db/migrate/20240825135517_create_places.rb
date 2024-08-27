class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.references :destination, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :name
      t.decimal :average_time_spent, precision: 4, scale: 2 # in hours
      t.decimal :min_cost, precision: 10, scale: 2
      t.decimal :max_cost, precision: 10, scale: 2
      # best time to visit in a day (morning, afternoon, evening, night)
      # point of interest/category (park, tourist_attraction, nightclub, beach, historical, temple, natural, etc.)

      t.timestamps
    end
  end
end
