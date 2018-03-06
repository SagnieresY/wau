class ProjectsGeo < ApplicationRecord
  belongs_to :geo
  belongs_to :project
  validates :geo, presence: true
  validates :project, presence: true
end
