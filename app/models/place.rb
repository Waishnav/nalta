class Place < ApplicationRecord
  belongs_to :destination
  has_many :activities

  enum category: { hotel: 0, restaurant: 1, attraction: 2, landmark: 3, park: 4, museum: 5, other: 6 }
end
