class Activity < ApplicationRecord
  belongs_to :place

  enum category: { adenture: 0, cultural: 1, fun: 2, other: 3 }
end
