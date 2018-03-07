class Milestone < ApplicationRecord
  belongs_to :investment
  validates :task, presence: true
  validates :amount, presence: true
  validates :deadline, presence: true
  validates :investment, presence: true
  def days_left
    #calculates the days left til deadline
    (deadline - Date.today).to_i #pretty much straight forward
  end
end
