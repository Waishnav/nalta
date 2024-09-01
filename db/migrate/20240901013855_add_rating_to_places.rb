class AddRatingToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :rating, :decimal, precision: 3, scale: 2
  end
end
