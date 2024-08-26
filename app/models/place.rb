class Place < ApplicationRecord
  belongs_to :destination
  has_many :activities

  enum category: { attraction: 0, landmark: 1, park: 2, museum: 3, nightlife: 4, shopping: 5, food: 6 }
end
