class CreatePlaceBestTimes < ActiveRecord::Migration[7.1]
  def change
    create_table :place_best_times do |t|
      t.references :place, null: false, foreign_key: true
      t.integer :best_time_to_visit, null: false

      t.timestamps
    end
  end
end
