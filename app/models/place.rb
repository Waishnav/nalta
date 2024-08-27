class Place < ApplicationRecord
  belongs_to :destination
  has_many :activities

  has_many :place_best_times
  has_many :best_times_to_visit, through: :place_best_times
  enum best_time_to_visit: { morning: 0, afternoon: 1, evening: 2, night: 3 }

  has_many :point_of_interests
  has_many :categories, through: :point_of_interests
  enum category: {
    beach: 0, lake: 1, shopping_mall: 2, art_gallery: 3, landscaping: 4, nightlife: 5,
    entertainment: 6, park: 7, tourist_attraction: 8, historic_site: 9, temple: 10,
    monument: 11, art: 12, nightclub: 13, viewpoint: 14, animal_shelter: 15, nature_reserve: 16,
    water_park: 17, zoo: 18, aquarium: 19, climbing: 20, cave: 21, waterfall: 22
  }
end
