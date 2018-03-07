class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
  def projects_by_nearest_milestone
    #get projects
    #get their first milestones
    #order these
    projects.sort do |a,b|
      a.nearest_milestone.deadline <=> b.nearest_milestone.deadline
    end

  end
end
