class InvestmentsController < ApplicationController

  def index
    @fuck_off_pundit = policy_scope(current_user.organisation.investments.first)
    @active_investments = Kaminari.paginate_array(current_user.organisation.uncompleted_investments.sort_by{|i| i.next_installment&.days_left}).page(params[:page]).per(10)
    @completed_investments = Kaminari.paginate_array(current_user.organisation.completed_investments).page(params[:page]).per(10)

    respond_to do |format|
      format.js  { render 'index.js.erb' }
      format.html
    end
  end

  def new
    @investment = Investment.new
    @investment.project = Project.new
    @investment.installments << Installment.new(task:t("form.investment.installment.sub_task"), deadline: Date.today, investment: @investment, amount: 10)
    authorize @investment
  end

  def create
    project = Project.create_with_check(params.to_unsafe_h[:investment][:project_attributes][:organisation],params.to_unsafe_h[:investment][:project_attributes])
    @investment = Investment.new(investment_params)
    @investment.organisation = current_user.organisation
    @investment.project = project
    authorize @investment

    if @investment.save && @investment.installments.count == 0
      @investment.installments << Installment.create!(task:t("form.investment.installment.sub_task"), deadline: Date.today, investment: @investment, amount: 0)
      flash[:notice] = "Investment successfully created"
      redirect_to investment_path(@investment)

    elsif @investment.save && @investment.installments.count > 0
      flash[:notice] = "Investment successfully created"
      redirect_to investment_path(@investment)

    else
      flash[:notice] = "Couldn't save!"
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
    params
      .require(:investment).permit(
        :project_id,
        installments_attributes: Installment.attribute_names.map(&:to_sym).push(:_destroy),
        project_attributes: [:name,:description,:focus_area_id,:main_contact,{ :geo_ids => [] }, :_destroy, :organisation_id])
  end

end
