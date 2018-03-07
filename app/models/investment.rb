class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
  has_many :milestones
  validates :project, presence: true
  validates :foundation, presence: true
  def projected_amount
    #calculates projected amount minus the missed milestones
    valid_milestones = milestones.map do |m| #map passed deadline (if the milestone task was done or is b4 deadline)
      m.accessible ? m.amount : 0
    end

    valid_milestones.reduce(0, :+) #sums the valid milestones and returns it
  end

  def given_amount
    unlocked_milestones_amount = milestones.map {|m| m.unlocked ? m.amount : 0} #maps unlocked milestones

    unlocked_milestones_amount.reduce(0, :+) #sums unlocked milestones and returns it
  end

  def milestones_by_nearest_deadline
    milestones.order('deadline ASC') #returns an array of milestone by the nearest deadline
  end
end
