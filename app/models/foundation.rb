class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investments
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
  def projects_by_nearest_milestone
    #get projects
    #filter out the investments w/out milestonesg
    #get their first milestones
    #order these
    sorted_projects = projects.reject{|p| !p.milestones.any?}.sort do |a,b|
      a.nearest_milestone.deadline <=> b.nearest_milestone.deadline
    end
    sorted_projects.uniq
  end

  def total_forecasted_amount
    projects.map(&:total_funding).reduce(0,:+)
  end

  def projects_by_focus_area
    projects.group_by{ |project| project.focus_area  }
  end

  def focus_areas
    focus_areas = projects.map(&:focus_area).uniq
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

  def total_unlocked_amount
    investments.map(&:unlocked_amount).reduce(0,:+)
  end
end
