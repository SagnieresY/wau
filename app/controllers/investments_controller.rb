class InvestmentsController < ApplicationController
  def index
    #milestn

    @fuck_off_pundit = policy_scope(current_user.organisation.investments.first)
    @active_investments = current_user.organisation.uncompleted_investments.sort_by{|i| i.next_installment&.days_left}

    @completed_investments = current_user.organisation.completed_investments

    #installment
    #organisation projects where they have investments
        #total funding with projects
        #project name
        #next installment time left
        #project description
 #Installment
        #edit button => edit form
  end

  def new

    @investment = Investment.new
    authorize @investment
  end

  def create
    @investment = Investment.new(investment_params)
    @investment.organisation = current_user.organisation
    @investment.installments << Installment.create!(task:'first installment for investment', deadline: Date.today, investment: @investment, amount: 0)
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
    #installments for project
        #amount for installment
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
