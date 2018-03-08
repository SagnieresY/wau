class PagesController < ApplicationController
  def home
    #todo read chart maker doc
    #upcoming milestones for each project
        #project name
        #projectect amount
        #given amount
        #task
        #time left


      if current_user.foundation

        @projects = current_user.foundation.projects_by_nearest_milestone
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

  def no_foundation
    render layout: false
    redirect_to root_path if current_user
  end
end
