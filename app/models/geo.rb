class Geo < ApplicationRecord
  has_many :projects_geos
  has_many :projects, through: :projects_geos
  validates :name, presence: true, uniqueness: true
end
