

class Foundation < ApplicationRecord
  MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :installments, through: :investments
  validates :name, presence: true, uniqueness: true
  def completed_investments
    investments.where(completed:true)
  end

  def uncompleted_investments
    investments.where(completed:false)
  end

  def upcoming_installments # accessible installments for the next 365 days
    installments.select{|i| i.deadline < (Date.today + 365) && !i.rescinded?}
  end

  def unlocked_installments
    installments.where(status:"unlocked")
  end

  def next_installments # array of next installments of investments
    uncompleted_investments.map(&:next_installment)
  end

  def locked_installments
    installments.where(status:"locked")
  end

  def amount_unlocked #amount given via installments that are unlocked
    unlocked_installments.map(&:amount).reduce(0,:+)
  end

  def amount_for_year #forecasted amount for the upcoming 365 days
    upcoming_installments.map(&:amount).reduce(0,:+)
  end

end


# class Foundation < ApplicationRecord
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
