class Project < ApplicationRecord
  has_many :projects_geos
  has_many :geos, through: :projects_geos
  has_many :investments
  has_many :milestones, through: :investments
  validates :name, presence: true
  validates :description, presence: true
  validates :ngo, presence: true
  validates :focus_area, presence: true
  validates :main_contact, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    message: "Please enter an valid email" }
  def nearest_milestone
    milestones.order('deadline ASC').select{|m|  !m.unlocked}.detect(&:accessible?)
     #orders project milestones by deadline then select the first one
  end

  def milestones_by_deadline
    milestones.order('deadline ASC')
  end

  def nearest_milestone_index
    milestones.count - milestones.select{|m| !m.unlocked}.count
  end

  def total_funding
    milestones.map(&:amount).reduce(0,:+)
  end

  def milestones_by_month
    milestones.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => milestones
  end

  def milestones_by_month_unlocked
    milestones_unlocked = []
    milestones.each do |milestone|
      if milestone.unlocked == true
        milestones_unlocked << milestone
      end
    end
    milestones_unlocked.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => milestones
  end

 def milestones_by_month_locked
    milestones_locked = []
    milestones.each do |milestone|
      if milestone.unlocked == false
        milestones_locked << milestone
      end
    end
    milestones_locked.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => milestones
  end

end
