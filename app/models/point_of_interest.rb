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
    historical_landmark: 8,
    religious_places: 9,
    monument: 10,
    nature_reserve: 11,
    water_park: 12,
    zoo: 13,
    aquarium: 14,
    hiking: 15,
    cave: 16,
    waterfall: 17
  }
end

# nightlife =  casino, night_club, bar, pub
# adventure = hiking_area, climbing_area, waterfall,
# fun = bowling_alley, amusement_park, water_park, zoo, aquarium
# park = amusement_park, amusement_center, 
# religious_places = temple, church, mosque
# shopping = shopping_mall, market
# 
