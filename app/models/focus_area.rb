class FocusArea < ApplicationRecord
	translates :name

  def self.forecasted_amount_by_focus_area(organisation)
    output = {unlocked: {},locked: {}}
    invest_by_fa = organisation.investments.group_by{|invest| invest.project.focus_area.name}
    invest_by_fa.each do |k,v|
      output[:unlocked][k] = v.map(&:unlocked_amount).reduce(0,:+)
      output[:locked][k] = v.map(&:locked_amount).reduce(0,:+)
    end
    return output
  end
end

