class ProjectsController < ApplicationController
  def new
    @project = Project.new
    authorize @project
  end

  def create
    authorize @project
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
end
