class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
  def next_milestones
    #get projects
    #filter out the investments w/out milestonesg
    #get their first milestones
    #order these
    sorted_milestones = investments.map(&:next_milestone)
  end

  def total_donations_amount
    projects.map(&:total_funding).reduce(0,:+)
  end

  def projects_by_focus_area
    focus_areas = projects.map(&:focus_area).uniq
    projects.group_by{ |project| project.focus_area  }
  end
end
