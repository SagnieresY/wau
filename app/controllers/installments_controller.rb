class InstallmentsController < ApplicationController
  before_action :selected_installment, only: [:edit, :update, :destroy, :unlock, :rescind ]
  before_action :find_investment, only: [:create, :new, :edit, :update, :destroy]
#Installment
  def new
    @installment = Installment.new
    authorize @investment
  end

  def create
    @installment = Installment.new(installment_params)

    @installment.investment = @investment
    authorize @investment
    if @installment.save
      redirect_to investment_path(@investment)
    else
      render :new
      #redirect_to new_investment_installment_path(@installment)
    end
  end

  def edit
    authorize @installment
    authorize @investment
    @investment.completed?
  end

  def update
    authorize @installment
    @installment.update!(installment_params)
    @installment.save!
    @installment.investment.completed?
    puts installment_params
    redirect_to investment_path(@investment)
  end

  def destroy
    authorize @installment
    @installment.destroy
    redirect_to investment_path(@investment)
  end

  def unlock
    authorize @installment
    @investment = @installment.investment
    @installment.unlock!
    @investment.completed? #check if investment is completed

    # render json: {
    #   installment: @installment,
    #   stats: @installment.investment.unlocked_amount
    # }
    @page = params[:page]
    if true
      # reset_global_variables
      respond_to do |format|
        format.html { unlock_installment_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'investment/show'}
        format.js
      end
    end
  end

  def lock
    authorize @installment
    @installment.lock!
    @investment = @installment.investment
  end

  def rescind
    #only way to rescind installment
    authorize @installment
    @investment = @installment.investment
    @installment.rescind!
    @investment.completed? #check if investment is completed

    @page = params[:page]
    if true
      # reset_global_variables
      respond_to do |format|
        format.html { rescind_installment_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'investment/show'}
        format.js
      end
    end
  end

  private

  def installment_params
    params.require(:installment).permit(:task,:amount,:deadline, :id, :status)
  end

  def find_investment
    @investment = Investment.find(params[:investment_id])
  end

  def selected_installment
    @installment = Installment.find(params[:id])
  end

  # def reset_global_variables
  #   @investments_by_month_locked_cummulative = current_user.organisation.cummulative_locked_amount_investment_by_installments_deadline_month
  #   @investments_by_month_unlocked_cummulative = current_user.organisation.cummulative_unlocked_amount_investment_by_installments_deadline_month

  #   investments_by_focus_area = current_user.organisation.investments_by_focus_area.map do |focus_area, investments|
  #     [focus_area,investments.map(&:forecasted_amount).reduce(0,:+)]
  #   end
  #   @investments_by_focus_area = investments_by_focus_area.to_h


  # end
end
