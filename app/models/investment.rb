class Investment < ApplicationRecord

  belongs_to :foundation
  belongs_to :project
  has_many :installments
  validates :project, presence: true
  validates :foundation, presence: true
#installment
  def forecasted_amount
    #calculates projected amount minus the missed installments
    valid_installments = installments.map do |m| #map passed deadline (if the installment task was done or is b4 deadline)
      !m.rescinded? ? m.amount : 0
    end

    valid_installments.reduce(0, :+) #sums the valid installments and returns it
  end

  def unlocked_amount
    unlocked_installments_amount = installments.map {|m| m.unlocked? ? m.amount : 0} #maps unlocked installments
    unlocked_installments_amount.reduce(0, :+) #sums unlocked installments and returns it
  end

  def locked_amount
    forecasted_amount - unlocked_amount
  end

  def installments_by_nearest_deadline
    installments.order('deadline ASC') #returns an array of installment by the nearest deadline
  end

  def next_installment
    installments_by_nearest_deadline.select{|m| m.locked? }.first
  end

  def last_installment
    installments_by_nearest_deadline.last
  end

  def completed?
    update!(completed:true) if installments.reject{ |m|  m.unlocked? || m.rescinded?}.blank?
    update!(completed:false) unless installments.reject{ |m|  m.unlocked? || m.rescinded?}.blank?
    return completed
  end
end
