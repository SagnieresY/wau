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
        @installments = current_user.organisation.next_installments.sort_by{|m| !m.days_left}
        @investments_by_focus_area = current_user.organisation.investments_by_focus_area
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
