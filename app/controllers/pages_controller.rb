class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:home,:landing]
  def home
    #installment
    #Milestone
    #todo read chart maker doc
    #upcoming installments for each project
        #project name
        #projectect amount
        #given amount
        #task
        #time leftr

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

          # .group_by_year(:deadline, range: current_year)

          # TAKES LOCKED INVESTMENTS AND RETURNS CUMULATED HASH BY FOCUS AREA
          @cumulated_fa_locked_amount = {}
          @locked_installments = @locked_installments.where("extract(year from deadline) = #{@year}")
          @locked_installments.each do |installment|
            focus_area = installment.focus_area.name
            amount = installment.amount
            if @cumulated_fa_locked_amount.key?(focus_area)
                unless amount.nil?
                @cumulated_fa_locked_amount[focus_area] += amount
                else amount.nil?
                @cumulated_fa_locked_amount[focus_area] = 0
              end
            else
                @cumulated_fa_locked_amount[focus_area] = amount
            end
          end
          @cumulated_fa_locked_amount

          # TAKES UNLOCKED INVESTMENTS AND RETURNS CUMULATED HASH BY FOCUS AREA
          @cumulated_fa_unlocked_amount = {}
          @unlocked_installments = @unlocked_installments.where("extract(year from deadline) = #{@year}")
          @unlocked_installments.each do |installment|
            focus_area = installment.focus_area.name
            amount = installment.amount
            if @cumulated_fa_unlocked_amount.key?(focus_area)
                unless amount.nil?
                @cumulated_fa_unlocked_amount[focus_area] += amount
                else amount.nil?
                @cumulated_fa_unlocked_amount[focus_area] = 0
              end
            else
                @cumulated_fa_unlocked_amount[focus_area] = amount
            end
          end
        # @years_of_service = Installment.years_of_service(current_user.organisation)
      else
        redirect_to no_organisation_path
      end
  end

  def dashboard
    #Prepares the installments for graphs / tables and includes investment, focus_area and projects in the query
    # @locked_installments = current_user.organisation.locked_installments.includes( :investment, :focus_area, :project)
    # @unlocked_installments = current_user.organisation.unlocked_installments.includes(:investment, :focus_area, :project)


    #Sets current year as start / end date
    t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
    start_date = t.beginning_of_year
    end_date = t.end_of_year

    #Updates to filter for specific time range if there is one
    if !params[:min_date].blank? || !params[:min_date].blank?
        
      #Makes (string)date into DATETIME object
      min_date = params[:min_date].to_time
      max_date = params[:max_date].to_time


      #Picks smallest date as start date
      start_date = min_date < max_date ? min_date : max_date
      end_date = max_date > min_date ? max_date : min_date
    end

    #Formats date for chart
    @start_date = start_date.strftime("%d/%m/%Y")
    @end_date = end_date.strftime("%d/%m/%Y")

    #Get installments with date range and joins tables
    @installments = current_user.organisation.installments.where(deadline: start_date..end_date).includes(:investment, :project, :focus_area, :organisation)

    #Updates installments with GEO selection if there is one
    unless params[:neighborhood].blank?
      geos_array = params[:neighborhood].split(',')
      @installments = @installments.joins(:geos).where("geos.name":geos_array)
    end

    #Updates installments with FOCUSAREA selection if there is one
    unless params[:focus].blank?
      fa_hash = {}
      fa_array_id = []
      FocusArea.all.each {|fa| fa_hash[fa.name] = fa.id}
      params[:focus].gsub('and','&').delete(' ').split(',').each {|fa| fa_array_id << fa_hash[fa]}
      @installments = @installments.joins(:focus_area).where('focus_areas.id':fa_array_id)
      byebug
    end

    #Updates installments with NGO selection if there is one
    unless params[:ngo].blank?
      org_array = params[:ngo].gsub('and','&').split(',')
      @installments = @installments.joins(project: :organisation).where("organisations.name":org_array)
      byebug
    end

    unless params[:project].blank?
      project_array = params[:project].gsub('and','&').split(',')
      @installments = @installments.joins(:project).where("projects.name":project_array)
    end

    #Calculate year range
    time_range_seconds = (max_date.to_i - start_date.to_i)

    #Return hash by TIME depending on range
    if (time_range_seconds) > 63115201
      @locked_installments_time_chart = @installments.locked.group_by_year(:deadline, format: "%Y", range: start_date..end_date).sum(:amount)
      @unlocked_installments_time_chart = @installments.unlocked.group_by_year(:deadline, format: "%Y", range: start_date..end_date).sum(:amount)
    else
      @locked_installments_time_chart = @installments.locked.group_by_month(:deadline, format: "%b %Y", range: start_date..end_date).sum(:amount)
      @unlocked_installments_time_chart = @installments.unlocked.group_by_month(:deadline, format: "%b %Y", range: start_date..end_date).sum(:amount)
    end

    #Returns hash by GEO & sum(:amount)
    @locked_installments_geo_chart = @installments.locked.joins(:geos).group("geos.name").sum(:amount)
    @unlocked_installments_geo_chart = @installments.unlocked.joins(:geos).group("geos.name").sum(:amount)
    
    # #Returns hash by NGO & sum(:amount)
    @locked_installments_ngo_chart = @installments.locked.joins(project: :organisation).group("organisations.name").sum(:amount)
    @unlocked_installments_ngo_chart = @installments.unlocked.joins(project: :organisation).group("organisations.name").sum(:amount)
    
    #Returns hash by FA & sum(:amount)
    @locked_installments_fa_chart = @installments.locked.joins(:focus_area).group('focus_areas.id').sum(:amount)
    @unlocked_installments_fa_chart = @installments.unlocked.joins(:focus_area).group('focus_areas.id').sum(:amount)

    @locked_installments_project_chart = @installments.locked.joins(:project).group('projects.name').sum(:amount)
    @unlocked_installments_fa_chart = @installments.unlocked.joins(:project).group('projects.name').sum(:amount)

    #Returns installments grouped by investments for TABLE
    installment_ids = @installments.ids
    @investments = Investment.joins(:installments).where("installments.id":installment_ids).distinct
  end

  def landing
    render :layout => false
  end

  def no_organisation
  end
  
  def downloads
  end


end
