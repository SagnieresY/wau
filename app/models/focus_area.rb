 class FocusArea < ApplicationRecord
	has_many :projects
  has_many :investments, through: :projects
  has_many :installments, through: :investments

  translates :name
  include PgSearch
  has_many :focus_area_translations
  multisearchable against: [ :name ]
  pg_search_scope :search_by_name,
    associated_against: {
      focus_area_translations: [ :name ]
    },
    using: {
      tsearch: { prefix: true }
    }

  def year_range(year)
    # Returns a Time Range of year.
    # To be used with GROUP_BY_ (GROUPDATE)
    t = Time.new(year,1,1,0,0,0,'+00:00')
    t.beginning_of_year..t.end_of_year
  end

  def unlocked_installments
    installments.where(status:"unlocked")
  end

  def unlocked_amount
    unlocked_installments.sum(:amount)
  end

  def unlocked_amount_year_range(year)
    unlocked_installments.group_by_year(:deadline, range: year_range(year), format: "%Y").sum(:amount)[year]
  end

  def locked_installments
    installments.where(status:"locked")
  end

  def locked_amount
    locked_installments.sum(:amount)
  end

  def locked_amount_year_range(year)
    locked_installments.group_by_year(:deadline, range: year_range(year), format: "%Y").sum(:amount)[year]
  end

  def rescinded_installments
    installments.where(status:"rescinded")
  end

  def rescinded_amount
    rescinded_installments.sum(:amount)
  end

  def self.forecasted_amount_by_focus_area(organisation)
    installments = organisation.upcoming_installments
    installments_by_status = installments.group_by{|inst| inst.status.to_sym}
    output = {locked:{},unlocked:{}}
    installments_by_status.each do |status, installments|
      installments_by_status[status].each do |installment|
        unless output[status][installment.focus_area.name]
          output[status][installment.focus_area.name] = installment.amount
        else
          output[status][installment.focus_area.name] += installment.amount
        end
      end
    end
    return FocusArea.chart_formating(output)
  end

  def self.chart_formating(data)
    output = {locked:{},unlocked:{}}
    data.each do |status, subhash|
      data[status].each do |subkey, subvalue|
        output[:locked][subkey] = 0
        output[:unlocked][subkey] = 0
      end
    end
    data.each do |status, subhash|
      data[status].each do |subkey, subvalue|
        output[status][subkey] = subvalue
      end
    end
    output.each do |status, data|
      output[status] = output[status].sort.to_h
    end
    return output
  end
end

