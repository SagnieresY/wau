class InvestmentsController < ApplicationController
  def index
    @fuck_off_pundit = policy_scope(current_user.foundation.investments.first)
    @active_investments = current_user.foundation.active_investments.sort_by{|i| i.next_milestone&.days_left}

    @completed_investments = current_user.foundation.completed_investments


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
    @investment = Investment.new(investment_params)
    @investment.foundation = current_user.foundationd10n
    @investment.milestones << Milestone.create!(task:'first installment for investment', deadline: Date.today, investment: @investment, amount: 0)
    authorize @investment

    if @investment.save
      redirect_to investment_path(@investment)
    else
      render :new
    end
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

  def unlocked_amount
    authorize selected_investment
    selected_investment.unlocked_amount

    render json: selected_investment.unlocked_amount
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
