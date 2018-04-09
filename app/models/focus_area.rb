class FocusArea < ApplicationRecord
	translates :name
  include PgSearch
  multisearchable against: [:name]
  pg_search_scope :search_by_name,
   associated_against: {
     focus_area_translations: [ :name ]
   },
   using: {
     tsearch: { prefix: true } # <-- now `superman batm` will return something!
   }
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
    return FocusArea.chart_formating(output)
  end

  def self.chart_formating(data)
    output = {locked:{},unlocked:{}}
    data.each do |status, subhash|
      data[status].each do |subkey, subvalue|
        output[:locked][subkey] = 0
        output[:unlocked][subkey] = 0
      end
    end
    data.each do |status, subhash|
      data[status].each do |subkey, subvalue|
        output[status][subkey] = subvalue
      end
    end
    output.each do |status, data|
      output[status] = output[status].sort.to_h
    end
    return output
  end



end

