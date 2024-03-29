class Organisation < ApplicationRecord
  include PgSearch
  multisearchable against: [ :name ]
  pg_search_scope :search_by_name,
    against: [:name],
    using: {
      tsearch: { prefix: true }
    }
  has_many :users, dependent: :destroy
  has_many :investments, inverse_of: :organisation, dependent: :destroy
  has_many :installments, through: :investments, dependent: :destroy
  has_many :projects, through: :investments, dependent: :destroy
  has_many :installments, through: :investments, dependent: :destroy
  has_many :focus_areas, through: :investments
  has_many :investment_tags
  validates :name, presence: true, uniqueness: true
  validates :charity_number, uniqueness: true, format: { with: /\d{9}[A-Z]{2}\d{4}/i, message: "Please enter an valid charity id" }

  attribute :name


  def self.create!(organisation_attributes) #improved project create!
    organisations = Organisation.where(name:organisation_attributes[:name]) #gets organisation by name

    if organisations.blank? #check if a organisation whith the name exists
      return super(organisation_attributes) #if not it creates it
    end

    return organisations[0] #if yes it returns it
  end

  def destroy
    installments.each{|i| i.destroy!}
    investments.each{|i| i.destroy!}
    projects.where(organisation: self).each{|i| i.destroy}
    super
  end

  def completed_investments
    investments.where(status:"completed")
  end

  def active_investments
    investments.where(status:"active")
  end

  def rejected_investments
    investments.where(status:"rejected")
  end

  def permitted_investments
    investments.where(status:["active","completed"])
  end

  def investments_by_focus_area(completed = false)
    investments.includes(:project)
               .includes(:focus_area)
               .select{|i| i.completed == completed}.group_by{|i| i.project.focus_area.name}
  end

  def upcoming_installments # accessible installments for the next 365 days
    installments.select{|i| i.deadline < (Date.today + 365) && !i.rescinded?}
  end

  def unlocked_installments
    installments.where(status:"unlocked") #array of unlocked installments
  end

  def locked_installments
    installments.where(status:"locked") #array of locked installments
  end

  def rescinded_installments
    installments.where(status:"rescinded")  #array of rescinded installments
  end

  def next_installments # array of next installments of investments
    active_investments.map(&:next_installment)
  end

  def unlocked_amount #amount given via installments that are unlocked
    unlocked_installments.sum(:amount)
  end

  def locked_amount #amount given via installments that are unlocked
    locked_installments.sum(:amount)
  end

  def amount_for_year #forecasted amount for the upcoming 365 days
    upcoming_installments.map(&:amount).reduce(0,:+)
  end

  def amount_by_ngo #hash of invested amount(locked & unlocked) by ngo
    output = {unlocked: {},locked: {}}
    invest_by_ngo = investments.group_by{|invest| invest.project.organisation.name}
    invest_by_ngo.each do |k,v|
      output[:unlocked][k] = v.map(&:unlocked_amount).reduce(0,:+)
      output[:locked][k] = v.map(&:locked_amount).reduce(0,:+)
    end
    output[:locked] = Organisation.otherify(output[:locked])
    output[:unlocked] = Organisation.otherify(output[:unlocked])

    output
  end

  def amount_by_neighborhood
    output = {unlocked: {},locked: {}}
    invest_by_ngo = investments.group_by{|invest| invest.project.geos.map(&:name).to_s.gsub(/(\W)/,'-')}
    invest_by_ngo.each do |k,v|
      output[:unlocked][k] = v.map(&:unlocked_amount).reduce(0,:+)
      output[:locked][k] = v.map(&:locked_amount).reduce(0,:+)
    end
    output[:locked] = Organisation.otherify(output[:locked])
    output[:unlocked] = Organisation.otherify(output[:unlocked])

    output
  end

  def year_range(year)
    # Returns a Time Range of year.
    # To be used with GROUP_BY_ (GROUPDATE)
    t = Time.new(year,1,1,0,0,0,'+00:00')
    t.beginning_of_year..t.end_of_year
  end

  def self.otherify(hash)
    # Takes all focus areas and outputs biggest 8 individually, then next as "others"
    main_focuses = hash.sort{ |focus, amount| focus[1]<=>amount[1] }.reverse[(0..8)].to_h
    if hash.count > 8
      others = hash.sort{ |focus, amount| focus[1]<=>amount[1] }.reverse[(9..-1)]
      others = others.map{|focus| focus[1]}.reduce(0,:+)
      main_focuses["Others"] = others
      main_focuses
    else
      main_focuses
    end
  end

  def locked_amount_by_focus_area_year(year)
    # Will iterate through all focus_areas and cumulate the locked amounts
    locked = {}
    focus_areas.each do |fa|
      name = fa.name
      amount = fa.locked_amount_year_range(self, year)
      if locked.key?(name)
          unless amount.nil?
          locked[name] += amount
          end
      elsif amount.nil?
          locked[name] = 0
      else
          locked[name] = amount
      end
    end
    Organisation.otherify(locked)
  end

  def unlocked_amount_by_focus_area_year(year)
    # Will iterate through all focus_areas and cumulate the unlocked amounts
    unlocked = {}
    focus_areas.each do |fa|
      name = fa.name
      amount = fa.unlocked_amount_year_range(self, year)
      if unlocked.key?(name)
          unless amount.nil?
          unlocked[name] += amount
          end
      elsif amount.nil?
          unlocked[name] = 0
      else
          unlocked[name] = amount
      end
    end
    Organisation.otherify(unlocked)
  end
#COMMENT

  # NOT USED IN HOME CHARTS ANYMORE
  def amount_by_date_cumulative
    amounts_by_date = Installment.amount_by_date(self)
    amounts_by_date.each do |status, dates|
      sum = 0
      amounts_by_date[status].each do |date, amount|
        sum += amount
        amounts_by_date[status][date] = sum
      end
    end
    return amounts_by_date
  end

  def receiving_organisations
    project_ids = self.projects.ids
    @receiving_organisations = []
    self.projects.includes(:organisation).where("projects.id":project_ids).each {|p| @receiving_organisations << p.organisation}
    @receiving_organisations.uniq
  end
end


# class Organisation < ApplicationRecord
#   MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
#   has_many :users, dependent: :destroy
#   has_many :investments, dependent: :destroy
#   has_many :projects, through: :investments
#   has_many :installments, through: :investments
#   validates :name, presence: true, uniqueness: true
#   def next_installments
#     #get projects
#     #filter out the investments w/out installmentsg
#     #get their first installments
#     #order these
#     installments = investments.map(&:next_installment) #compact gets rid of nil values
#     return installments.compact.sort_by{|m| m.days_left}.reverse
#   end

#   def investments_by_focus_area
#     focus_areas = projects.map(&:focus_area).uniq
#     investments.group_by{ |investment| investment.project.focus_area  }
#   end

#   def total_forecasted_amount
#   #calculates projected amount minus the missed installments
#     valid_installments = installments.map do |m| #map passed deadline (if the installment task was done or is b4 deadline)
#       !m.rescinded? ? m.amount : 0
#     end

#     valid_installments.reduce(0, :+) #sums the valid installments and returns it
#   end

#   def projects_by_focus_area
#     focus_areas = projects.map(&:focus_area).uniq
#     projects.group_by{ |project| project.focus_area  }
#   end

#   def installments_by_month
#     installments.group_by{|m| Date::MONTHNAMES[m.deadline.month]}
#   end

#   def accessible_installments_by_month
#     accessible_installments = []
#     installments.map do |installment|
#       if installment.rescinded?
#         accessible_installments << installment
#       end
#     end
#     accessible_installments.group_by{|m| Date::MONTHNAMES[m.deadline.month]}
#   end

#   def unlocked_amount_investment_by_installments_deadline_month
#     output = accessible_installments_by_month.map do |month, installments|
#       [month,sum_unlocked_installments(installments)]
#     end

#     output = output.to_h
#     MONTHS.each do |month|
#         unless output[month]
#           output[month] = 0
#         end
#       end
#     output
#   end

#   def locked_amount_investment_by_installments_deadline_month
#     output = accessible_installments_by_month.map do |month, installments|
#       [month,sum_locked_installments(installments)]
#     end
#     output = output.to_h
#     MONTHS.each do |month|
#         unless output[month]
#           output[month] = 0
#         end
#     end
#     output
#   end

#   def cummulative_locked_amount_investment_by_installments_deadline_month
#       sum = 0
#       updated_hash = self.locked_amount_investment_by_installments_deadline_month
#       updated_hash.each do |k, v|
#         sum += updated_hash[k]
#         updated_hash[k] = sum
#       end


#       updated_hash
#     end

#     def cummulative_unlocked_amount_investment_by_installments_deadline_month
#       sum = 0
#       updated_hash = unlocked_amount_investment_by_installments_deadline_month
#       updated_hash.each do |k, v|
#         sum += updated_hash[k]
#         updated_hash[k] = sum
#       end
#       updated_hash
#   end

#   def total_unlocked_amount
#     investments.map(&:unlocked_amount).reduce(0,:+)
#   end
#   def total_locked_amount
#     investments.map(&:locked_amount).reduce(0,:+)
#   end

#   def active_investments
#     investments.where(completed:false)
#   end

#   def completed_investments
#     investments.where(completed:true)
#   end

#   def completed_investments_count
#     #calculates projected amount minus the missed installments
#     completed_investments.count
#   end

#   def completed_investments_by_time_created
#     investments.order('created_at ASC').select{|i| i.completed?}
#   end

#   def investments_by_ngo
#     investments.group_by{|i| i.project.ngo}
#   end

#   def forcasted_funding_by_ngo
#     investments_by_ngo.map{|ngo,investments| [ngo,sum_investments_forcasted(investments)]}.to_h
#   end

#   def unlocked_funding_by_ngo
#     investments_by_ngo.map{|ngo,investments| [ngo,sum_investments_given(investments)] }.to_h
#   end

#   def sum_investments_forcasted(investments)
#     investments.map(&:forecasted_amount).reduce(0,:+)
#   end

#   def sum_investments_given(investments)
#     investments.map(&:unlocked_amount).reduce(0,:+)
#   end

#   #NEW CHARTS METHODS
#   def accessible_deadlines_deadlines
#     installments.select{|i| !i.rescinded?}.map{|i| i.deadline}
#   end

#   def unlocked_installments_deadlines
#     installments.select{|i| i.unlocked?}.map{|i| i.deadline}
#   end

#   def unlocked_installments_amount
#     installments.select{|i| i.unlocked?}.map{|i| i.amount}
#   end

#   def locked_installments_deadlines
#     installments.select{|i| i.locked?}.map{|i| i.deadline}
#   end

#   def locked_installments_amount
#     installments.select{|i| i.locked?}.map{|i| i.amount}
#   end

#   private
#   def sum_locked_installments(installments)
#     installments.select{|m| m.locked?}.map(&:amount).reduce(0,:+)
#   end
#   def sum_unlocked_installments(installments)
#     installments.select{|m| m.unlocked?}.map(&:amount).reduce(0,:+)
#   end

# end
