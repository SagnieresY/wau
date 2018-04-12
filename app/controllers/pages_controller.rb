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
          @locked_installments = current_user.organisation.locked_installments.includes(:focus_area)
          @unlocked_installments = current_user.organisation.unlocked_installments.includes(:focus_area)

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
    #Prepares the installments for graphs / tables
    @locked_installments = current_user.organisation.locked_installments.includes(:focus_area, :geos, :organisation, :project )
    @unlocked_installments = current_user.organisation.unlocked_installments.includes(:focus_area, :geos, :organisation, :project)

    #Gets the current year and transforms it into a range
    t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
    @year = t.year
    current_year = t.beginning_of_year..t.end_of_year

    raw_next_installments = current_user.organisation.uncompleted_investments.map{|i| i.next_installment}
    @installments = raw_next_installments

    if !params[:min_date].blank? || !params[:max_date].blank?
      min_date = params[:min_date].blank? ? '' : Date.parse(params[:min_date])
      max_date = params[:max_date].blank? ? '' : Date.parse(params[:max_date])
      @installments = Installment.filter_by_date(@installments,min_date,max_date)
    end
    unless params[:focus_area].blank?
      @installments = Installment.filter_by_focus(@installments,params[:focus_area])
    end
    unless params[:ngo].blank?
      @installments = Installment.filter_by_ngo(@installments,params[:ngo])
    end
    unless params[:neighborhood].blank?
      @installments = Installment.filter_by_neighborhood(@installments,params[:neighborhood])
    end
    unless params[:project].blank?
      @installments = Installment.filter_by_project(@installments, params[:project])
    end
  end


  def landing
    render :layout => false
  end

  def no_organisation
  end

end
