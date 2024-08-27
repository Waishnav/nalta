class CreatePointOfInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :point_of_interests do |t|
      t.references :place, null: false, foreign_key: true
      t.integer :category, null: false

      t.timestamps
    end
  end
end
