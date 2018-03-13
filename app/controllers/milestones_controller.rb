class MilestonesController < ApplicationController

  before_action :selected_milestone, only: [:edit, :update, :destroy, :unlock, :decline ]
  before_action :find_investment, only: [:create, :new, :edit, :update, :destroy]

  def new
    @milestone = Milestone.new
    authorize @investment
  end

  def create
    @milestone = Milestone.new(milestone_params)

    @milestone.investment = @investment
    authorize @investment
    if @milestone.save
      redirect_to investment_path(@investment)
    else
      render :new
      #redirect_to new_investment_milestone_path(@milestone)
    end
  end

  def edit
    authorize @milestone
    authorize @investment
  end

  def update
    authorize @milestone
    @milestone.update(milestone_params)
    redirect_to investment_path(@investment)
  end

  def destroy
    authorize @milestone
    @milestone.destroy
    redirect_to investment_path(@investment)
  end

  def unlock
    authorize @milestone
    @milestone.unlocked = true
    @milestone.save!
    @investment = @milestone.investment

    @investment.completed? #check if investment is completed

    # render json: {
    #   milestone: @milestone,
    #   stats: @milestone.investment.unlocked_amount
    # }
    @page = params[:page]
    if @milestone.save
      @investments_by_month_locked_cummulative = current_user.foundation.cummulative_locked_amount_investment_by_milestones_deadline_month
      @investments_by_month_unlocked_cummulative = current_user.foundation.cummulative_unlocked_amount_investment_by_milestones_deadline_month

      respond_to do |format|
        format.html { unlock_milestone_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'investment/show'}
        format.js
      end
    end
  end

  def decline
    authorize @milestone
    @milestone.accessible = false
    @milestone.save!

    render json: @milestone
  end

  private

  def milestone_params
    params.require(:milestone).permit(:task,:amount,:deadline, :id)
  end

  def find_investment
    @investment = Investment.find(params[:investment_id])
  end

  def selected_milestone
    @milestone = Milestone.find(params[:id])
  end
end
