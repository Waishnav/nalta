class Place < ApplicationRecord
  belongs_to :destination
  has_many :place_best_times
  has_many :point_of_interests
end
