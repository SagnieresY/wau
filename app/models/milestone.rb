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

  def accessible?
    accessible
  end

  def meme
    investment.milestones.order('deadline ASC').each_with_index do |m,i|
      if m.id = id
        return i
      end
    end
  end
end
