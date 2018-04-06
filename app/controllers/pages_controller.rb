class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:home,:landing]
  def home()
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

        unless params["year"]
          year = Date.today.year
          @installments = Installment.next_installments_of_year(current_user.organisation,year).sort_by{|m| !m.days_left}

        else
          year = params["year"].to_i
          @installments = Installment.next_installments_of_year(current_user.organisation,year).sort_by{|m| !m.days_left}
        end
        @investments_by_focus_area = current_user.organisation.investments_by_focus_area
        @chart_focus_area_data = FocusArea.forecasted_amount_by_focus_area(current_user.organisation)
        @chart_ngo_data = current_user.organisation.amount_by_ngo
        @chart_installments_data = current_user.organisation.amount_by_date_cumulative
        @years_of_service = Installment.years_of_service(current_user.organisation)
      else
        redirect_to no_organisation_path
      end
  end

  def dashboard
    #get installment
    raw_next_installments = current_user.organisation.investments.map{|i| i.next_installment}

    #filter by date
    if params[:min_date] || params[:max_date]
      installments = Installment.filter_by_date(raw_next_installments,params[:min_year],params[:max_year])
    end
    #filter by focus area
    if params[:focus]
      installments = Installment.filter_by_focus(installments,params[:focus_area])
    end

    #filter by ngo

    #filter by neighborhood

    #add results
  end

  def landing
    render :layout => false
  end

  def no_organisation

  end

end
