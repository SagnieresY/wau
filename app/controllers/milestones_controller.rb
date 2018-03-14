class MilestonesController < ApplicationController

  before_action :selected_milestone, only: [:edit, :update, :destroy, :unlock, :rescind ]
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
    edit_params = milestone_params
    if edit_params[:unlocked]
      edit_params[:accessible] = true
    end
    @milestone.update(edit_params)
    @milestone.unlocked?
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
    @milestone.accessible = true #makes sure investment is accessible
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

      investments_by_focus_area = current_user.foundation.investments_by_focus_area.map do |focus_area, investments|
        [focus_area,investments.map(&:forecasted_amount).reduce(0,:+)]
      end
      @investments_by_focus_area = investments_by_focus_area.to_h

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

  def lock
    authorize @milestone
    @milestone.unlocked = false
    @milestone.accessible = true #makes sure investment is accessible
    @milestone.save!
    @investment = @milestone.investment
  end

  def rescind
    #only way to rescind milestone
    authorize @milestone
    @milestone.accessible = false
    @milestone.unlocked = false #makes sure investment is not counted in unlocked
    @milestone.save!
    @investment = @milestone.investment

    @investment.completed? #check if investment is completed

    @page = params[:page]
    if @milestone.save
      @investments_by_month_locked_cummulative = current_user.foundation.cummulative_locked_amount_investment_by_milestones_deadline_month
      @investments_by_month_unlocked_cummulative = current_user.foundation.cummulative_unlocked_amount_investment_by_milestones_deadline_month

      investments_by_focus_area = current_user.foundation.investments_by_focus_area.map do |focus_area, investments|
        [focus_area,investments.map(&:forecasted_amount).reduce(0,:+)]
      end
      @investments_by_focus_area = investments_by_focus_area.to_h

      respond_to do |format|
        format.html { rescind_milestone_path }
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

  def milestone_params
    params.require(:milestone).permit(:task,:amount,:deadline, :id, :unlocked, :accessible)
  end

  def find_investment
    @investment = Investment.find(params[:investment_id])
  end

  def selected_milestone
    @milestone = Milestone.find(params[:id])
  end
end
