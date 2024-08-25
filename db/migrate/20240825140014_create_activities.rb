class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :place, foreign_key: true
      t.string :name
      t.text :description
      t.integer :average_time_spent  # in minutes
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.integer :category
      t.decimal :cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end
