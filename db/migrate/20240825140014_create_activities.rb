class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :place, foreign_key: true
      t.string :name
      t.decimal :average_time_spent, precision: 4, scale: 2
      t.integer :category
      t.decimal :cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end
