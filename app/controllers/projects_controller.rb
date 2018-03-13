class ProjectsController < ApplicationController
  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      new_investment = Investment.create!(project: @project,foundation: current_user.foundation)
      redirect_to investment_path(new_investment)
    else
      render :new
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
  end

  def destroy
    authorize @project
  end

  private
  def project_params
    params.require(:project).permit(:name,:description,:ngo,:focus_area,:main_contact,:geos)
  end
end
