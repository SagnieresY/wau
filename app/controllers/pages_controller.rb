class PagesController < ApplicationController
  def home
    #todo read chart maker doc
    #upcoming milestones for each project
        #project name
        #projectect amount
        #given amount
        #task
        #time left
      @projects = current_user.foundation.projects_by_nearest_milestone
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
end
