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
          @installments = Kaminari.paginate_array(Installment.next_installments_of_year(current_user.organisation,year).sort_by{|m| !m.days_left}).page(params[:page]).per(25)

        else
          year = params["year"].to_i
          @installments = Kaminari.paginate_array(Installment.next_installments_of_year(current_user.organisation,year).sort_by{|m| !m.days_left}).page(params[:page]).per(25)
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

    #investment index
      #project name
      #project type
      #completed
      #total given
      #last installment
      #Milestone unlocked
      #trust worthy level (dependent on installments unlocked?)
  end

  def landing
    render :layout => false
  end

  def no_organisation

  end

end
