class Country < ApplicationRecord
  has_many :destinations

  validates :name, presence: true, uniqueness: true
end
