
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
          t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
          current_year = t.beginning_of_year..t.end_of_year

          current_year_locked_installments = current_user.organisation.locked_installments.where("extract(year from deadline) = #{t.year}")
          @first_page_locked_installments = current_year_locked_installments.sort_by(&:deadline).group_by(&:investment_id).collect{|k,v| v.first}.first(25)
          
          current_year_unlocked_installments = current_user.organisation.locked_installments.group_by_year(:deadline, range: current_year)
        # NOT USED IN HOME CHARTS ANYMORE
        # @years_of_service = Installment.years_of_service(current_user.organisation)
        # @chart_focus_area_data = FocusArea.forecasted_amount_by_focus_area(current_user.organisation)
        # @chart_ngo_data = current_user.organisation.amount_by_ngo
        # @chart_installments_data = current_user.organisation.amount_by_date_cumulative 
        # @investments_by_focus_area = current_user.organisation.investments_by_focus_area
      else
        redirect_to no_organisation_path
      end
  end

  def dashboard
    raw_next_installments = current_user.organisation.uncompleted_investments.map{|i| i.next_installment}
    @installments = raw_next_installments
    if params[:focus_area].present?
      @installments = Installment.filter_by_focus(@installments,params[:focus_area])
    end
    if params[:ngo].present?
      @installments = Installment.filter_by_ngo(@installments,params[:ngo])
    end
    if params[:neighborhood].present?
      @installments = Installment.filter_by_neighborhood(@installments,params[:neighborhood])
    end
    if params[:project].present?
      @installments = Installment.filter_by_project(@installments, params[:project])
    end


    @chart_focus_area_data = FocusArea.forecasted_amount_by_focus_area(current_user.organisation)
    @chart_ngo_data = current_user.organisation.amount_by_ngo
    @chart_installments_data = current_user.organisation.amount_by_date_cumulative
    @years_of_service = Installment.years_of_service(current_user.organisation)
  end


  def landing
    render :layout => false
  end

  def no_organisation
  end

end