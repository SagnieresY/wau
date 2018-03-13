class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:home,:landing]
  def home
    #todo read chart maker doc
    #upcoming milestones for each project
        #project name
        #projectect amount
        #given amount
        #task
        #time leftr


      if current_user.nil?
        render :landing

      elsif current_user.foundation

        @milestones = current_user.foundation.next_milestones
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
      #last milestone unlocked
      #trust worthy level (dependent on milestones unlocked?)
  end

  def landing

  end

  def no_foundation

  end

end
