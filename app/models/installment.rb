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

  def self.amount_by_date(organisation)
    installments = organisation.upcoming_installments
    installments_by_status = installments.group_by{|inst| inst.status.to_sym}

    output = {locked:{},unlocked:{}}
    installments_by_status.each do |status, installments|
      installments_by_status[status].each do |installment|
        unless output[status][installment.deadline.to_s]
          output[status][installment.deadline.to_s] = installment.amount
        else
          output[status][installment.deadline.to_s] += installment.amount
        end
      end
    end
    return FocusArea.chart_formating(output)
  end

  def self.years_of_service(organisation)
    chronogolical_installments_deadlines = organisation.installments.sort_by(&:deadline).map(&:deadline)
    first_deadline = chronogolical_installments_deadlines.first
    last_deadline = chronogolical_installments_deadlines.last
    output =  *(first_deadline.year..last_deadline.year)
  end

  def self.next_installments_of_year(organisation,year)
    organisation.next_installments.select{|i| i.deadline.year == year}
  end

  def self.filter_by_date(installments,min_date,max_date)
    min_date = Date.new(-2000,1,1) if min_date.blank?
    max_date = Date.new(9999,1,1) if max_date.blank?
    installments.select{|i| i.deadline > min_date && i.deadline < max_date}
    min_date = Date.new(-2000,1,1) unless min_date
    max_date = Date.new(9999,1,1) unless max_date
    installments.select{|i| i.deadline > min_date && i.deadline < max_date}
  end

  def self.filter_by_focus(installments,focus)
    installments.select{|i| i.investment.project.focus_area.name == focus}
  end

  def self.filter_by_ngo(installments,ngo)
    installments.select{|i| i.investment.project.organisation.name == ngo}
  end

  def self.filter_by_neighborhood(installments,neighborhood)
    installments.select{|i| i.investment.project.geos.map(&:name).include?(neighborhood)}
  end

  def self.filter_by_params(installments,params)

    if (params[:min_date] || params[:max_date]) && params[:date_search] == "1"
      installments = Installment.filter_by_date(installments,params[:min_year],params[:max_year])

    end

    #filter by focus area
    if params[:focus_area] && params[:focus_area_search] == "1"
      installments = Installment.filter_by_focus(installments,params[:focus_area])

    end

    #filter by ngo
    if params[:ngo] && params[:ngo_search] == "1"
      installments = Installment.filter_by_ngo(installments,params[:ngo])
    end
    #filter by neighborhood
    if params[:neighborhood] && params[:neighborhood_search] == "1"
      installments = Installment.filter_by_neighborhood(installments,params[:neighborhood])
    end

    return installments

    installments.select{|i| i.investment.project.geos.map(&:name).include?(neighborhood)}
  end
end
