class FocusArea < ApplicationRecord
	translates :name

  def self.forecasted_amount_by_focus_area(organisation)
    installments = organisation.upcoming_installments
    installments_by_status = installments.group_by{|inst| inst.status.to_sym}

    output = {locked:{},unlocked:{}}
    installments_by_status.each do |status, installments|
      installments_by_status[status].each do |installment|
        unless output[status][installment.investment.project.focus_area.name]
          output[status][installment.investment.project.focus_area.name] = installment.amount
        else
          output[status][installment.investment.project.focus_area.name] += installment.amount
        end
      end
    end
    return output
  end
end

