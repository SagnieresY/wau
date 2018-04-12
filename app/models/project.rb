class Project < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name,
    against: [ :name ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

  has_and_belongs_to_many :geos
  has_many :investments, inverse_of: :project, dependent: :destroy
  has_many :installments, through: :investments, dependent: :destroy
  belongs_to :focus_area
  belongs_to :organisation
  validates :name, presence: true
  validates :description, presence: true
  validates :focus_area, presence: true
  validates :geos, presence: true
  validates :main_contact, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    message: "Please enter an valid email" }
  accepts_nested_attributes_for :investments

  def nearest_installment
    installments.order('deadline ASC').select{|m|  !m.unlocked}.detect(&:accessible?)
     #orders project installments by deadline then select the first one
  end

  def unlocked_installments
    installments.where(status:"unlocked")
  end

  def unlocked_amount
    unlocked_installments.sum(:amount)
  end

  def locked_installments
    installments.where(status:"locked")
  end

  def locked_amount
    locked_installments.sum(:amount)
  end

  def rescinded_installments
    installments.where(status:"rescinded")
  end

  def rescinded_amount
    rescinded_installments.sum(:amount)
  end

  def installments_by_deadline
    installments.order('deadline ASC')
  end

  def nearest_installment_index
    installments.count - installments.select{|m| !m.unlocked}.count
  end

  def total_funding
    installments.sum(:amount)
  end

  def installments_by_month
    installments.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => installments
  end

  def installments_by_month_unlocked
    installments.unlocked.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => installments
  end

  def installments_by_month_locked
    installments.locked.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => installments
  end

   def installments_by_month_rescinded
    installments.rescinded.group_by{|m| Date::MONTHNAMES[m.deadline.month] } #returns hash of months => installments
  end

  def self.create_with_check(receiving_name, attributes = {})
    if Organisation.exists?(name: receiving_name)
      organisation = Organisation.find_by(name: receiving_name)
    else
      organisation = Organisation.new(name: receiving_name)
      organisation.save!
    end
    attributes[:organisation] = organisation
    project = self.new(attributes)
    project.save!
    project
  end
end
