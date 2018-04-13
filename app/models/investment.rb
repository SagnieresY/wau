class Investment < ApplicationRecord

  belongs_to :organisation
  belongs_to :project
  has_one :focus_area, through: :project
  has_many :installments, dependent: :destroy
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
    installments.locked.sum(:amount)
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

  def self.to_csv(organisation)
      attributes = %w{id created_at project_id forecasted_amount unlocked_amount locked_amount completed? }
      CSV.generate(headers: true) do |csv|
        csv << attributes

        organisation.investments.each do |investment|
          csv << attributes.map{ |attr| investment.send(attr) }
        end
      end
  end

  def to_a
    [id,project_id,completed?,forecasted_amount,unlocked_amount,locked_amount]
  end
end
