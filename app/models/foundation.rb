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
    sorted_milestones = investments.map(&:next_milestone)
  end

  def total_donations_amount
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

  def total_unlocked_amount
    investments.map(&:unlocked_amount).reduce(0,:+)
  end
end
