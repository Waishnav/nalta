class PlaceBestTime < ApplicationRecord
  belongs_to :place

  enum best_time_to_visit: { dawn: 0, morning: 1, afternoon: 2, evening: 3, night: 4 }
end
