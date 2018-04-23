class ProjectsController < ApplicationController
  skip_after_action :verify_authorized, only: :search

  def project_csv

    authorize current_user.organisation.projects.first
    data_string = ""
    current_user.organisation.investments.each do |investment|
      investment.installments.each do |installment|
        data_string += "#{investment.project.name},#{investment.project.description},#{investment.project.organisation.name},#{investment.project.main_contact},#{installment.task},#{installment.amount},#{installment.deadline.to_s},#{installment.status}\n"
      end
    end
    send_data data_string, filename: "Projects-#{Date.today.to_s}.csv", type: 'text/csv'
  end

  def generate_projects

    authorize current_user
    projects_csv = params[:projects_csv] #file
    projects_attributes = []
    installments_attributes = []
    File.open(projects_csv.path,"r") do |f| #reads file
      f.each do |line|
        projects_attributes.push(line.split(',')[0..3]) #seperates project info
        installments_attributes.push(line.split(',')[4..8]) #seprates installment info
      end
    end
    byebug
    current_project = ''
    investment_obj = ''
    projects_attributes.each_with_index do |project, index|
      current_installment = installments_attributes[index] #gets installments info for project
      organisation_obj = Organisation.create!(name:project[2])
      project_obj = Project.create!(name:project[0],description:project[1],organisation:organisation_obj,main_contact:project[3],main_contact:project[4])
      unless current_project == project[0]
        investment_obj = Investment.create!(project:project_obj,organisation:current_user.organisation)
      end
      Installment.create!(investment:investment_obj,task:current_installment[0],amount:current_installment[1],deadline:Date.parse(current_installment[2]),status:current_installment[3].chomp)
      current_project = project[0]
    end

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
