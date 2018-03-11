class MilestonesController < ApplicationController

  before_action :selected_milestone, only: [:edit, :update, :destroy, :unlock, :decline ]

  def new
    @milestone = Milestone.new
    @investment = investment
    authorize investment
  end

  def create
    new_milestone = Milestone.new(milestone_params)
    new_milestone.investment = investment
    authorize investment
    new_milestone.save!
    redirect_to investment_path(investment)
  end

  def edit
    authorize @milestone
    @investment = investment
    authorize investment
  end

  def update
    authorize @milestone
    @milestone.update(milestone_params)
    redirect_to investment_path(investment)
  end

  def destroy
    authorize @milestone
    @milestone.destroy
    redirect_to investment_path(investment)
  end

  def unlock
    authorize @milestone
    @milestone.unlocked = true
    @milestone.save!

    render json: @milestone
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

  def investment
    Investment.find(params[:investment_id])
  end

  def selected_milestone
    @milestone = Milestone.find(params[:id])
  end
end
