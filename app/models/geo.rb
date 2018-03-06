class Geo < ApplicationRecord
  has_many :projects_geos
  has_many :projects, through: :projects_geos
end
