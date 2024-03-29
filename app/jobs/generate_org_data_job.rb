class GenerateOrgDataJob < ApplicationJob
  queue_as :low_priority
  def perform(installments,org)

    headers = installments.delete_at(0).split(',')

    tag_index = headers.index('Tag')
    geo_index = headers.index('Geo')

    current_investment = ''
    main_query = ''
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

      main_query += "('#{installment_info[1]}', #{installment_info[2]}, '#{installment_info[3]}', '#{installment_info[4]}', #{current_investment.id}, '#{Date.today.to_s}', '#{Date.today.to_s}'),"
    end

    ActiveRecord::Base.connection.execute("INSERT INTO installments
      (task, amount, deadline, status, investment_id, created_at, updated_at)
      VALUES
      #{main_query.chop}")


    # Do something later

  end
end
