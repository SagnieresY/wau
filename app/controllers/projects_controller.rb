class ProjectsController < ApplicationController
  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to investments_path
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
