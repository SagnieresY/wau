class Investment < ApplicationRecord

  belongs_to :organisation, inverse_of: :investments
  belongs_to :project, inverse_of: :investments
  has_one :focus_area, through: :project
  has_one :focus_area_translations, through: :project
  has_many :installments, dependent: :destroy
  has_many :geos, through: :project
  validates :project, presence: true
  validates :organisation, presence: true
  accepts_nested_attributes_for :project
  accepts_nested_attributes_for :installments,
                                allow_destroy: true,
                                reject_if: proc { |att| att['amount'].blank? }

  scope :completed, -> { where(completed: 'true') }
  scope :active, -> {where(completed: 'false')}

#installment
  def forecasted_amount
    #calculates projected amount minus the missed installments
    installments.unlocked.sum(:amount) + installments.locked.sum(:amount)
  end

  def unlocked_amount
    installments.unlocked.sum(:amount)
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

  def active_year
    active_year = []
    installments.each {|i| active_year << i.year if active_year.exclude?(i.year)}
    active_year
  end
end
