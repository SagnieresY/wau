class InvestmentsController < ApplicationController
  def index
    authorize @investment
    #foundation projects where they have investments
        #total funding with projects
        #project name
        #next milestone time left
        #project description
        #edit button => edit form
  end

  def new
    @investment = @investment.new
    authorize @investment
    #form
  end

  def create
    authorize @investment
    # normal
  end

  def edit
    authorize @investment
    #normal
  end

  def update
    authorize @investment
    #normal
  end

  def show
    authorize @investment
    #milestones for project
        #amount for milestone
        #task
        #time due
        #time left
        #total amount if all unlocked
        #currently gaved
  end

  def destroy
    authorize @investment
  end

end
