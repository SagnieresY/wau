class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
  def projects_by_nearest_milestone
    #get projects
    #filter out the investments w/out milestones
    #get their first milestones
    #order these
    sorted_projects = projects.reject{|p| !p.milestones.any?}.sort do |a,b|
      a.nearest_milestone.deadline <=> b.nearest_milestone.deadline
    end
    sorted_projects.uniq
  end
end
