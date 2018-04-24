class ProjectsController < ApplicationController
  skip_after_action :verify_authorized, only: :search

  def project_csv(investments = current_user.organisation.investments.dup)

    authorize current_user.organisation.projects.first

    geos_amount = investments.sort_by{|invest| invest.project.geos.count}.last.project.geos.count
    tags_amount = investments.sort_by{|invest| invest.investment_tags.count}.last.investment_tags.count
    data_string = "Project Name, Project Description, Receiving Organisation, Charity ID, Project Contact Email, Project Focus Area, Investment Status, Installment index, Installment Task, Installment Amount, Installment Deadline, Installment status,#{'Geo,'*geos_amount}#{'Tag,'*tags_amount}\n"

    investments.each do |investment|
      investment.installments_by_nearest_deadline.each do |installment|
        project = installment.investment.project
        data_string += "#{project.name},#{project.description},#{project.organisation.name},#{project.organisation.charity_number},#{project.main_contact},#{project.focus_area.name.gsub(',','|')},#{investment.status}, #{installment.investment_index.to_i + 1},#{installment.task},#{installment.amount},#{installment.deadline.to_s},#{installment.status}"
        data_string += ",#{investment.geos.map(&:name).join(',')}#{', '*(geos_amount-investment.geos.count)}"
        data_string += ",#{investment.investment_tags.map(&:name).join(',')}#{', '*(tags_amount-investment.investment_tags.count)}"
        data_string += "\n"
      end
    end

    send_data data_string, filename: "Projects-#{Date.today.to_s}.csv", type: 'text/csv'
  end

  def generate_projects

    authorize current_user
    projects_csv = params[:projects_csv] #file

    full_data = []
    File.open(projects_csv.path,"r") do |f| #reads file
      full_data = f.read.split("\n")
    end
     GenerateOrgDataJob.perform_now(full_data,current_user.organisation)
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
    .permit(:name,:description,:focus_area_id,:main_contact,{ :geo_ids => [] },
      installments_attributes: Installment.attribute_names.map(&:to_sym).push(:_destroy))
  end

  def selected_project
    @project = Project.find(params[:id])
  end
end
