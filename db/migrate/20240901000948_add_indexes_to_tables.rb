class AddIndexesToTables < ActiveRecord::Migration[7.1]
  def change
    add_index :countries, :code unless index_exists?(:countries, :code)

    # Add indexes to destinations table
    add_index :destinations, [:latitude, :longitude] unless index_exists?(:destinations, [:latitude, :longitude])

    # Add indexes to places table
    add_index :places, :name, unique: true unless index_exists?(:places, :name, unique: true)

    # Add index to point_of_interests table
    add_index :point_of_interests, :category unless index_exists?(:point_of_interests, :category)
  end
end
