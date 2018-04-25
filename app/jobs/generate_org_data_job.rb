class GenerateOrgDataJob < ApplicationJob
  queue_as :low_priority
  def perform(installments,org)

    headers = installments.delete_at(0).split(',')

    tag_index = headers.index('Tag')
    geo_index = headers.index('Geo')
    installments_instances = []
    current_investment = ''

    installments.each do |installment|
      installment = installment.split(',')
      if installment[7].to_i == 1
        project = installment[0..5]
        project_geos = installment[geo_index..(tag_index.nil? ? -1 : tag_index)].reject{|e| e == ' '|| e.empty?}.map{|geo| Geo.create(name:geo)}
        project = Project.create!(name:project[0],description:project[1],organisation:Organisation.create!(name:project[2],charity_number:project[3].to_i),main_contact:project[4],geos:project_geos,focus_area:FocusArea.search_by_name(project[5].gsub('|',',')).first)

        current_investment = Investment.new(project:project,organisation:org,status:installment[6])
        investment_tags = tag_index.nil? ? [] : installment[tag_index..-1]..reject{|e| e == ' '|| e.empty?}

        tags = investment_tags.map{|tag| InvestmentTag.create(name:tag,organisation:org)}
        current_investment.investment_tags = tags
        current_investment.save!
      end
      installment_info = installment[7..11]
      installments_instances.push(Installment.new(task:installment_info[1],amount:installment_info[2],deadline:Date.parse(installment_info[3]),status:installment_info[4],investment:current_investment))

    end
    installments_instances.each { |inst| inst.save!(validate: false )}


    # Do something later

  end
end
