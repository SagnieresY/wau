class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
  has_many :milestones
  validates :project, presence: true
  validates :foundation, presence: true
  def projected_amount
    #calculates projected amount minus the missed milestones
    valid_milestones = milestones.map do |m| #check if deadline passed or if the milestone task was done
      Date.today > m.deadline || m.unlocked ? 0 : m.amount
    end
    valid_milestones.reduce(0, :+)
  end


end
