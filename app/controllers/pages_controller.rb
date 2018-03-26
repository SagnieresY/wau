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
      elsif current_user.foundation
        @installments = current_user.foundation.next_installments.sort_by{|m| !m.days_left}
        @investments_by_month_locked_cummulative = current_user.foundation.cummulative_locked_amount_investment_by_installments_deadline_month
        @investments_by_month_unlocked_cummulative = current_user.foundation.cummulative_unlocked_amount_investment_by_installments_deadline_month

        investments_by_focus_area = current_user.foundation.investments_by_focus_area.map do |focus_area, investments|
          [focus_area,investments.map(&:forecasted_amount).reduce(0,:+)]
        end
        @investments_by_focus_area = investments_by_focus_area.to_h

      else
        redirect_to no_foundation_path
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

  def no_foundation

  end

end
