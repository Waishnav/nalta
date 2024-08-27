class PlaceBestTime < ApplicationRecord
  belongs_to :place

  enum best_time_to_visit: { morning: 0, afternoon: 1, evening: 2, night: 3 }
end
