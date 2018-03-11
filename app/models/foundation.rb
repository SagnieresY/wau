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
    milestones = investments.map(&:next_milestone)
    milestones.sort_by{|m| m.days_left}.reverse
  end

  def total_forecasted_amount
    projects.map(&:total_funding).reduce(0,:+)
  end

  def projects_by_focus_area
    focus_areas = projects.map(&:focus_area).uniq
    projects.group_by{ |project| project.focus_area  }
  end

  def projects_by_milestones_deadline_month
    output = {"January"=>[],"February"=>[],"March"=>[],"April"=>[],"May"=>[],"June"=>[],"July"=>[],
"August"=>[],"September"=>[],"October"=>[],"November"=>[],"December"=>[]}
    projects.reduce do |_,project|
      project.milestones_by_month.each do |month,milestones|
        milestones.each do |milestone|
          if output[month].nil?
             output[month] = milestone

          else
             output[month].push(milestone)
          end
        end
      end
    end
    output = output.map{ |month, milestones| [month,milestones.map(&:amount)]}.to_h #gets the amounts
    output = output.map{ |month, milestones| milestones = milestones.reduce(0,:+); [month,milestones]}.to_h
    return output
  end

  def unlocked_amount_investment_by_milestones_deadline_month
    output = {"January"=>[],"February"=>[],"March"=>[],"April"=>[],"May"=>[],"June"=>[],"July"=>[],
"August"=>[],"September"=>[],"October"=>[],"November"=>[],"December"=>[]}
    projects.reduce do |_,project|
      project.milestones_by_month_unlocked.each do |month,milestones|
        milestones.each do |milestone|
          if output[month].nil?
             output[month] = milestone

          else
             output[month].push(milestone)
          end
        end
      end
    end
    output = output.map{ |month, milestones| [month,milestones.map(&:amount)]}.to_h #gets the amounts
    output = output.map{ |month, milestones| milestones = milestones.reduce(0,:+); [month,milestones]}.to_h
    return output
  end

  def locked_amount_investment_by_milestones_deadline_month
    output = {"January"=>[],"February"=>[],"March"=>[],"April"=>[],"May"=>[],"June"=>[],"July"=>[],
"August"=>[],"September"=>[],"October"=>[],"November"=>[],"December"=>[]}
    projects.reduce do |_,project|
      project.milestones_by_month_locked.each do |month,milestones|
        milestones.each do |milestone|
          if output[month].nil?
             output[month] = milestone

          else
             output[month].push(milestone)
          end
        end
      end
    end
    output = output.map{ |month, milestones| [month,milestones.map(&:amount)]}.to_h #gets the amounts
    output = output.map{ |month, milestones| milestones = milestones.reduce(0,:+); [month,milestones]}.to_h
    return output
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
end
