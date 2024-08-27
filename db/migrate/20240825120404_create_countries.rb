class CreateCountries < ActiveRecord::Migration[7.1]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :countries, :name, unique: true
  end
end
