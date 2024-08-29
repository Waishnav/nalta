class PointOfInterest < ApplicationRecord
  belongs_to :place

  enum category: {
    beach: 0,
    lake: 1,
    shopping_mall: 2,
    art_gallery: 3,
    nightlife: 4,
    entertainment: 5,
    park: 6,
    tourist_attraction: 7,
    historic_site: 8,
    temple: 9,
    monument: 10,
    animal_shelter: 11,
    nature_reserve: 12,
    water_park: 13,
    zoo: 14,
    aquarium: 15,
    climbing: 16,
    cave: 17,
    waterfall: 18
  }
end
