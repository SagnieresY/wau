class MilestonesController < ApplicationController
  def new
    @milestone = Milestone.new
    authorize @milestone

  end

  def create
    authorize @milestone
  end

  def edit
    authorize @milestone
  end

  def update
    authorize @milestone
  end

  def destroy
    authorize @milestone
  end
end
