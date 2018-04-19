class ProjectsController < ApplicationController
  skip_after_action :verify_authorized, only: :search

  def project_csv

    authorize current_user.organisation.projects.first
    data_string = ""
    current_user.organisation.investments.each do |investment|
      investment.installments.each do |installment|
        data_string += "#{investment.project.name},#{investment.project.description}#{investment.project.main_contact},#{installment.task},#{installment.amount},#{installment.deadline.to_s}\n"
      end
    end
    send_data data_string, filename: "Projects-#{Date.today.to_s}.csv", type: 'text/csv'
  end

  def generate_projects

    authorize current_user
    projects_csv = params[:projects_csv]
    projects_attributes = []
    installments_attributes = []
    CSV.foreach(projects_csv.path) do |project|
      projects_attributes.push(project[0..3])
      installments_attributes.push(project[4..6])
    end
    raise
    redirect_to downloads_path

  end
  def search
    @projects = {results:[]}
    Project.search_by_name(params[:query]).uniq.each_with_index do |project, i|
      @projects[:results].push(project.name)
    end
    @projects[:results] = @projects[:results].uniq
    render json: @projects
  end

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
    params
    .require(:project)
    .permit(:name,:description,:focus_area_id,:main_contact,{ :geo_ids => [] }, installments_attributes: Installment.attribute_names.map(&:to_sym).push(:_destroy))
  end

  def selected_project
    @project = Project.find(params[:id])
  end
end
