class Installment < ApplicationRecord
  include PgSearch
  multisearchable against: [ :status, :amount, :deadline, :task ]
    pg_search_scope :search_by_task,
    against: :task,
    using: {
      tsearch: { prefix: true}
    }
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
    # installments.select{ |i| i.deadline > min_date && i.deadline < max_date}
    return installments

  end
  def self.installments_by_neighborhood(installments)
    return installments.group_by{|i| i.investment.project.geos}
  end
  def self.filter_by_focus(installments,focus_areas)
    focus_areas = focus_areas.gsub('and', '&').split(',')
    output = []
    focus_areas.each do |focus|
      installments.select{|i| i.investment.project.focus_area.name == focus}.each do |installment|
        output.push(installment)
      end
    end
    return output
  end

  def self.filter_by_ngo(installments,ngos)
    @output = []
    ngos = ngos.gsub('and', '&').split(',')
    ngos.each do |ngo|
      installments.select{|i| i.investment.project.organisation.name == ngo}.each do |installment|
        @output.push(installment)
      end
    end
    @output
  end

  def self.filter_by_neighborhood(installments,neighborhoods)
    @output = []
    neighborhoods.gsub('and','&').split(',').each do |neighborhood|
      new_installments = installments.select{|i| i.investment.project.geos.map(&:name).include?(neighborhood)}
      new_installments.each do |installment|
        @output.push(installment)
      end
    end
    @output
  end

  def self.filter_by_project(installments,projects)
    @output = []
    projects.gsub('and','&').split(',').each do |project|
      installments.select{|i| i.investment.project.name == project}.each do |installment|
        @output.push(installment)
      end
    end
    @output
  end

end
