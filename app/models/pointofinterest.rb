class PointOfInterest < ApplicationRecord
  belongs_to :place

  enum category: {
    beach: 0, lake: 1, shopping_mall: 2, art_gallery: 3, landscaping: 4, nightlife: 5,
    entertainment: 6, park: 7, tourist_attraction: 8, historic_site: 9, temple: 10,
    monument: 11, art: 12, nightclub: 13, viewpoint: 14, animal_shelter: 15, nature_reserve: 16,
    water_park: 17, zoo: 18, aquarium: 19, climbing: 20, cave: 21, waterfall: 22
  }
end
