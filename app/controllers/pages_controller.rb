class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:home,:landing]
  def home
      if current_user.nil?
        @bg = "bg-landing"
        render :landing
      elsif current_user.organisation

          #Gets the current year and transforms it into a range
          t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
          @year = t.year
          current_year = t.beginning_of_year..t.end_of_year

          #Used in home charts
          @locked_installments = current_user.organisation.locked_installments
          @unlocked_installments = current_user.organisation.unlocked_installments

          #Used in home locked table
          @first_page_locked_installments = @locked_installments
                                                                .where("extract(year from deadline) = #{@year}")
                                                                .sort_by(&:deadline)
                                                                .group_by(&:investment_id).collect{|k,v| v.first}
                                                                .first(25)

          locked_hash = @locked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)
          unlocked_hash = @unlocked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)

          locked_hash.keys.each { |k| locked_hash[FocusArea.find(k).name] = locked_hash.delete(k) }
          @locked_installments_fa_chart = locked_hash

          unlocked_hash.keys.each { |k| unlocked_hash[FocusArea.find(k).name] = unlocked_hash.delete(k) }
          @unlocked_installments_fa_chart = unlocked_hash

      else
        redirect_to no_organisation_path
      end
  end

  def dashboard

    #Sets current year as start / end date
    t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
    @start_date = t.beginning_of_year
    @end_date = t.end_of_year

    #Updates to filter for specific time range if there is one
    if !params[:min_date].blank? || !params[:min_date].blank?

      #Makes (string)date into DATETIME object
      min_date = params[:min_date].blank? ? Date.new(1800,1,1) : params[:min_date].to_time
      max_date = params[:max_date].blank? ? Date.new(2100,1,1) : params[:max_date].to_time

      #Picks smallest date as start date
      @start_date = min_date < max_date ? min_date : max_date
      @end_date = max_date > min_date ? max_date : min_date
    end

    #Formats date for chart
    @start_date_chart = @start_date.strftime("%d/%m/%Y")
    @end_date_chart = @end_date.strftime("%d/%m/%Y")

    #Get installments with date range and joins tables
    @installments = current_user.organisation.installments.where(deadline: @start_date..@end_date).includes(:investment, :project, :focus_area, :organisation)

    #Updates installments with GEO selection if there is one
    unless params[:neighborhood].blank?
      geos_array = params[:neighborhood].strip.gsub('and','&').gsub(', ',',').split(',')
      @installments = @installments.joins(:geos).where("geos.name":geos_array)
    end

    #Updates installments with FOCUSAREA selection if there is one
    unless params[:focus].blank?
      fa_hash = {}
      fa_array_id = []
      FocusArea.all.each {|fa| fa_hash[fa.name] = fa.id}

      params[:focus].strip.gsub('and','&').gsub(', ',',').split(',').each {|fa| fa_array_id << fa_hash[fa]}

      @installments = @installments.joins(:focus_area).where('focus_areas.id':fa_array_id)
    end

    #Updates installments with NGO selection if there is one
    unless params[:ngo].blank?

      org_array = params[:ngo].strip.gsub('and','&').gsub(', ',',').split(',')
      @installments = @installments.joins(project: :organisation).where("organisations.name":org_array)
    end

    unless params[:project].blank?
      project_array = params[:project].strip.gsub('and','&').gsub(', ',',').split(',')
      @installments = @installments.joins(:project).where("projects.name":project_array)
    end

    unless params[:tag].blank?
      tag_array = params[:tag].strip.gsub('and','&').gsub(', ',',').split(',' )
      @installments = @installments.joins(:investment_tags).where("investment_tags.name":tag_array)
    end

    if params[:unlocked].present? == false && params[:locked].present? == false && params[:rescinded].present? == false
      params[:unlocked] = true
      params[:locked] = true
    end

    @installment_ids_test =[]
    #checks if unlocked is selected and returns unlocked installments
    unlocked_selected?

    #checks if locked is selected and returns locked installments
    locked_selected?
    
    #checks if rescinded is selected and returns rescinded installments
    rescinded_selected?

    #Returns installments grouped by investments for TABLE
    installment_ids = @installments.ids
    @investments = Investment.joins(:installments).where("installments.id":@installment_ids_test.flatten).distinct
    # @installments_for_table = Installment.find(id=@installment_ids_test)
  end

  def landing
    render :layout => false
  end

  private

  def otherify(hash)
    otherified_hash = hash.sort{ |criteria, amount| criteria[1]<=>amount[1] }.reverse[(0..3)].to_h
    if hash.count > 3
      others = hash.sort{ |criteria, amount| criteria[1]<=>amount[1] }.reverse[(4..-1)]
      others = others.map{|criteria| criteria[1]}.reduce(0,:+)
      otherified_hash["OTHERS"] = others
      otherified_hash
    else
      otherified_hash
    end
  end



  def unlocked_selected?
    if params[:unlocked] && @installments.unlocked.sum(:amount) > 0 

      #Return hash by TIME depending on range
      @unlocked_installments_time_year = @installments.unlocked.group_by_year(:deadline, range: @start_date..@end_date).sum(:amount)
      @unlocked_installments_time_month = @installments.unlocked.group_by_month(:deadline, range: @start_date..@end_date).sum(:amount)
      @unlocked_installments_time_week = @installments.unlocked.group_by_week(:deadline, range: @start_date..@end_date).sum(:amount)
      @unlocked_installments_time_day = @installments.unlocked.group_by_day(:deadline, range: @start_date..@end_date).sum(:amount)

      #Returns hash by GEO & sum(:amount)
      @unlocked_installments_geo_chart = otherify(@installments.unlocked.joins(:geos).group("geos.name").sum(:amount))

      #Returns hash by NGO & sum(:amount)
      @unlocked_installments_ngo_chart = otherify(@installments.unlocked.joins(project: :organisation).group("organisations.name").sum(:amount))

      #Returns hash by FA & sum(:amount)
      unlocked_hash = @installments.unlocked.joins(:focus_area).group('focus_areas.id').sum(:amount)

      #Changes the keys of FA ID to FA NAME
      unlocked_hash.keys.each { |k| unlocked_hash[FocusArea.find(k).name] = unlocked_hash.delete(k) }
      @unlocked_installments_fa_chart = otherify(unlocked_hash)

      #Returns hash by PROJECT & sum(:amount)
      @unlocked_installments_project_chart = otherify(@installments.unlocked.joins(:project).group('projects.name').sum(:amount))

      #Returns hash by TAG & sum(:amount)
      @unlocked_installments_tag_chart = otherify(@installments.unlocked.joins(:investment_tags).group('investment_tags.name').sum(:amount))
      @installment_ids_test << @installments.unlocked.ids
    end
  end

  def locked_selected?
    if params[:locked] && @installments.locked.sum(:amount) > 0
      #Return hash by TIME depending on range
      @locked_installments_time_year = @installments.locked.group_by_year(:deadline, range: @start_date..@end_date).sum(:amount)
      @locked_installments_time_month = @installments.locked.group_by_month(:deadline, range: @start_date..@end_date).sum(:amount)
      @locked_installments_time_week = @installments.locked.group_by_week(:deadline, range: @start_date..@end_date).sum(:amount)
      @locked_installments_time_day = @installments.locked.group_by_day(:deadline, range: @start_date..@end_date).sum(:amount)

      #Returns hash by GEO & sum(:amount)
      @locked_installments_geo_chart = otherify(@installments.locked.joins(:geos).group("geos.name").sum(:amount))

      #Returns hash by NGO & sum(:amount)
      @locked_installments_ngo_chart = otherify(@installments.locked.joins(project: :organisation).group("organisations.name").sum(:amount))

      #Returns hash by FA & sum(:amount)
      locked_hash = @installments.locked.joins(:focus_area).group('focus_areas.id').sum(:amount)

      #Changes the keys of FA ID to FA NAME
      locked_hash.keys.each { |k| locked_hash[FocusArea.find(k).name] = locked_hash.delete(k) }
      @locked_installments_fa_chart = otherify(locked_hash)

      #Returns hash by PROJECT & sum(:amount)
      @locked_installments_project_chart = otherify(@installments.locked.joins(:project).group('projects.name').sum(:amount))

      #Returns hash by TAG & sum(:amount)
      @locked_installments_tag_chart = otherify(@installments.locked.joins(:investment_tags).group('investment_tags.name').sum(:amount))

      @installment_ids_test << @installments.locked.ids
    end
  end

  def rescinded_selected?
     if params[:rescinded] && @installments.rescinded.sum(:amount) > 0
      #Return hash by TIME depending on range
      @rescinded_installments_time_year = @installments.rescinded.group_by_year(:deadline, range: @start_date..@end_date).sum(:amount)
      @rescinded_installments_time_month = @installments.rescinded.group_by_month(:deadline, range: @start_date..@end_date).sum(:amount)
      @rescinded_installments_time_week = @installments.rescinded.group_by_week(:deadline, range: @start_date..@end_date).sum(:amount)
      @rescinded_installments_time_day = @installments.rescinded.group_by_day(:deadline, range: @start_date..@end_date).sum(:amount)
      
      #Returns hash by GEO & sum(:amount)
      @rescinded_installments_geo_chart = otherify(@installments.rescinded.joins(:geos).group("geos.name").sum(:amount))
      
      #Returns hash by NGO & sum(:amount)
      @rescinded_installments_ngo_chart = otherify(@installments.rescinded.joins(project: :organisation).group("organisations.name").sum(:amount))
      
      #Returns hash by FA & sum(:amount)
      rescinded_hash = @installments.rescinded.joins(:focus_area).group('focus_areas.id').sum(:amount)
      rescinded_hash.keys.each { |k| rescinded_hash[FocusArea.find(k).name] = rescinded_hash.delete(k) }
      
      #Changes the keys of FA ID to FA NAME
      @rescinded_installments_fa_chart = otherify(rescinded_hash)
      
      #Returns hash by PROJECT & sum(:amount)
      @rescinded_installments_project_chart = otherify(@installments.rescinded.joins(:project).group('projects.name').sum(:amount))
      
      #Returns hash by TAG & sum(:amount)
      @rescinded_installments_tag_chart = otherify(@installments.rescinded.joins(:investment_tags).group('investment_tags.name').sum(:amount))
      
      @installment_ids_test << @installments.rescinded.ids
    end
  end

end
