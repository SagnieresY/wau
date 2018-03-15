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
    @project = selected_project
    authorize @project
  end

  def update
    project = selected_project
    authorize project
    project.update(project_params)
    redirect_to investments_path
    authorize @project
  end

  def destroy
    authorize @project
  end

  private
  def project_params
    params.require(:project).permit(:name,:description,:ngo,:focus_area,:main_contact,:geos)
  end

  def selected_project
    @project = Project.find(params[:id])
  end
end
