class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
  has_many :milestones
  validates :project, presence: true
  validates :foundation, presence: true
  def projected_amount
    #calculates projected amount minus the missed milestones
  end
end
