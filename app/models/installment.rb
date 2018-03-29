class Installment < ApplicationRecord
  belongs_to :investment

  validates :status, inclusion: { in: %w(locked unlocked rescinded) }
  validates :task, presence: true
  validates :amount, presence: true
  validates :deadline, presence: true
  validates :investment, presence: true

  scope :unlocked, -> { where(status: 'unlocked') }
  scope :locked, -> { where(status: 'locked') }
  scope :rescinded, -> { where(status: 'rescinded') }

  def days_left
    #calculates the days left til deadline
    (deadline - Date.today).to_i #pretty much straight forward
  end

  def unlocked?
    #returns true if installment is not unlocked
    return status == "unlocked"
  end

  def locked?
    return status == "locked"
  end

  def rescinded?
    return status == "rescinded"
  end

  def unlock!
    return update(status:"unlocked")
  end

  def lock!
    return update(status:"locked")
  end

  def rescind!
    return update(status:"rescinded")
  end


  def investment_index
    investment.installments_by_nearest_deadline.index(self)
  end

end
