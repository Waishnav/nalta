class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.references :destination, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :name
      t.text :description
      t.integer :category
      t.integer :average_time_spent  # in minutes
      t.time :opening_hours
      t.time :closing_hours
      t.decimal :min_cost, precision: 10, scale: 2
      t.decimal :max_cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end