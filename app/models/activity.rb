class Activity < ApplicationRecord
  belongs_to :place

  enum category: { adventure: 0, cultural: 1, fun: 2, relaxation: 3, other: 4}
end
