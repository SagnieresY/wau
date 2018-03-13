class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
  def next_milestones
    #get projects
    #filter out the investments w/out milestonesg
    #get their first milestones
    #order these
    milestones = investments.map(&:next_milestone) #compact gets rid of nil values
    return milestones.compact.sort_by{|m| m.days_left}.reverse
  end

  def total_forecasted_amount
    milestones.map(&:amount).reduce(0,:+)
  end

  def projects_by_focus_area
    focus_areas = projects.map(&:focus_area).uniq
    projects.group_by{ |project| project.focus_area  }
  end

  def milestones_by_month
    milestones.group_by{|m| Date::MONTHNAMES[m.deadline.month]}
  end

  def unlocked_amount_investment_by_milestones_deadline_month
    output = milestones_by_month.map do |month, milestones|
      [month,sum_unlocked_milestones(milestones)]
    end
    return output.to_h
  end

  def locked_amount_investment_by_milestones_deadline_month
    output = milestones_by_month.map do |month, milestones|
      [month,sum_locked_milestones(milestones)]
    end
    return output.to_h
  end

  def cummulative_locked_amount_investment_by_milestones_deadline_month
      sum = 0
      updated_hash = self.locked_amount_investment_by_milestones_deadline_month
      updated_hash.each do |k, v|
        sum += updated_hash[k]
        updated_hash[k] = sum
      end
      updated_hash
    end

    def cummulative_unlocked_amount_investment_by_milestones_deadline_month
      sum = 0
      updated_hash = self.unlocked_amount_investment_by_milestones_deadline_month
      updated_hash.each do |k, v|
        sum += updated_hash[k]
        updated_hash[k] = sum
      end
      updated_hash
  end

  def total_unlocked_amount
    investments.map(&:unlocked_amount).reduce(0,:+)
  end
  def total_locked_amount
    investments.map(&:locked_amount).reduce(0,:+)
  end

  def ongoing_investments
    investments.where(completed:false)
  end

  def completed_investements
    investments.where(completed:true)
  end

  def completed_investments_by_time_created
    investments.order('created_at ASC').select{|i| i.completed?}
  end

  private
  def sum_locked_milestones(milestones)
    milestones.select{|m| !m.unlocked}.map(&:amount).reduce(0,:+)
  end
  def sum_unlocked_milestones(milestones)
    milestones.select{|m| m.unlocked}.map(&:amount).reduce(0,:+)
  end
end
