class MilestonesController < ApplicationController
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
    @milestone = selected_milestone
    authorize @milestone
  end

  def update
    milestone = selected_milestone
    authorize milestone
    milestone.update(milestone_params)
    redirect_to investment_path(investment)
  end

  def destroy
    authorize selected_milestone
    selected_milestone.destroy
    redirect_to investment_path(investment)
  end

  private
  def milestone_params
    params.require(:milestone).permit(:task,:amount,:deadline)
  end

  def investment
    Investment.find(params[:investment_id])
  end

    def selected_milestone
    Milestone.find(id)
  end
end
