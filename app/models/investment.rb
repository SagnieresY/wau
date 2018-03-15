class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
  has_many :milestones
  validates :project, presence: true
  validates :foundation, presence: true

  def forecasted_amount
    #calculates projected amount minus the missed milestones
    valid_milestones = milestones.map do |m| #map passed deadline (if the milestone task was done or is b4 deadline)
      m.accessible ? m.amount : 0
    end

    valid_milestones.reduce(0, :+) #sums the valid milestones and returns it
  end

  def unlocked_amount
    unlocked_milestones_amount = milestones.map {|m| m.unlocked ? m.amount : 0} #maps unlocked milestones
    unlocked_milestones_amount.reduce(0, :+) #sums unlocked milestones and returns it
  end

  def locked_amount
    forecasted_amount - unlocked_amount
  end

  def milestones_by_nearest_deadline
    milestones.order('deadline ASC') #returns an array of milestone by the nearest deadline
  end

  def next_milestone
    milestones_by_nearest_deadline.select{|m| !m.unlocked && m.accessible }.first
  end

  def last_milestone
    milestones_by_nearest_deadline.last
  end

  def completed?
    update!(completed:true) if milestones.reject{ |m|  m.unlocked || !m.accessible}.blank?
    update!(completed:false) unless milestones.reject{ |m|  m.unlocked || !m.accessible}.blank?
    return completed
  end
end
