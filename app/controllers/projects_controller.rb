class ProjectsController < ApplicationController
  def new
    @project = Project.new
    authorize @project
  end

  def create
    name = params[:project][:organisation]
    if Organisation.exists?(name: name)
      organisation = Organisation.find_by(name: name)
    else
      organisation = Organisation.new(name: name)
      organisation.save!
    end

    @project = Project.new(project_params)
    @project.organisation = organisation

    authorize @project

    if @project.save
      @investment = Investment.new(project:@project)
      @investment.installments << Installment.create!(task:'first installment for investment', deadline: Date.today, investment: @investment, amount: 0)
      @investment.organisation = current_user.organisation
      @investment.save!
      authorize @investment

      redirect_to investment_path(@investment)
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
    params.require(:project).permit(:name,:description,:focus_area_id,:main_contact,{ :geo_ids => [] })
  end

  def selected_project
    @project = Project.find(params[:id])
  end
end
