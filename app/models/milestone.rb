class Milestone < ApplicationRecord
  belongs_to :investment
  validates :task, presence: true
  validates :amount, presence: true
  validates :deadline, presence: true
  validates :investment, presence: true
  def time_left
    #calculates the time left til deadline
  end
end
