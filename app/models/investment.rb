class Investment < ApplicationRecord

  belongs_to :organisation, inverse_of: :investments
  belongs_to :project, inverse_of: :investments
  has_one :focus_area, through: :project
  has_one :focus_area_translations, through: :project
  has_many :installments, dependent: :destroy
  has_many :geos, through: :project
  has_and_belongs_to_many :investment_tags
  validates :project, presence: true
  validates :organisation, presence: true
  validates :status, presence: true, inclusion: { in: %w(active completed rejected) }
  accepts_nested_attributes_for :project
  accepts_nested_attributes_for :organisation,
                                allow_destroy: true,
                                reject_if: proc { |att| att['charity_number'].blank? }
  accepts_nested_attributes_for :installments,
                                allow_destroy: true,
                                reject_if: proc { |att| att['amount'].blank? }
  accepts_nested_attributes_for :investment_tags,
                                allow_destroy: true,
                                reject_if: proc { |att| att['name'].blank? }

  scope :completed, -> { where(status: 'completed') }
  scope :active, -> {where(status: 'active')}
  scope :rejected, -> {where(status: 'rejected')}
  scope :permitted_investments, -> {where(status: ['active', 'completed'])}

  def active?
    status == 'active'
  end

  def activate!
    update!(status:"active")
  end

  def completed?
    status == 'completed'
  end

  def complete!
    update!(status:"completed") if installments.reject{ |m|  m.unlocked? || m.rescinded?}.blank?
  end

  def rejected?
    status == 'rejected'
  end

  def reject!
    update!(status:"rejected")

    #make installments rescinded
    installments.each {|installment| installment.rescind!}
  end

  def update_status
    if installments.reject{ |m|  m.rescinded?}.blank?
      update!(status:"rejected") 
    elsif installments.reject{ |m|  m.unlocked? || m.rescinded?}.blank?
      update!(status:"completed") 
    else  
      update!(status:"active")
    end
  end

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
