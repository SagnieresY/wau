class InvestmentsController < ApplicationController
  def index
    @fuck_off_pundit = policy_scope(Investment)
    @investments = current_user.foundation.ongoing_investments
    authorize @investments

    #foundation projects where they have investments
        #total funding with projects
        #project name
        #next milestone time left
        #project description
        #edit button => edit form
  end

  def new

    @investment = Investment.new
    authorize @investment
  end

  def create
    new_investment = Investment.new(investment_params)
    new_investment.foundation = current_user.foundation
    authorize new_investment
    new_investment.milestones << Milestone.create!(task:'first milestone for investment',deadline:Date.today,investment:new_investment,amount:0)
    new_investment.save!
    redirect_to investment_path(new_investment)
  end

  def edit
    @investment = selected_investment
    authorize @investment
  end

  def update
    investment = selected_investment
    authorize investment
    investment.update(investment_params)
    redirect_to investment_path(selected_investment)
    authorize @investment
  end

  def show
    @investment = Investment.find(id)
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
    authorize selected_investment
    selected_investment.destroy
    redirect_to investments_path
  end

  private

  def id
    params[:id]
  end

  def selected_investment
    @investment= Investment.find(params[:id])
  end

  def investment_params
    params.require(:investment).permit(:project_id)
  end

end
