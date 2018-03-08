class ProjectsController < ApplicationController
  def new
    @project = Project.new
    authorize @project
  end

  def create

    new_project = Project.create!(project_params)
    authorize new_project
    redirect_to root_path
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
