class InvestmentsController < ApplicationController
  before_action :selected_investment, only:[:reject]
  skip_after_action :verify_authorized, only: [:search]

  def search
    @tags = {results:[]}
    InvestmentTag.search_by_name(params[:query]).uniq.each_with_index do |tag, i|
      @tags[:results].push(tag.name)
    end
    @tags[:results] = @tags[:results].uniq
    render json: @tags
  end

  def index
    @fuck_off_pundit = policy_scope(current_user.organisation.investments.last)
    @active_investments =  active_investments_paginated
    @completed_investments = completed_investments_paginated

    @page = "active_page" if params.has_key?(:active_page)
    @page = "completed_page" if params.has_key?(:completed_page)
  end

  def completed_index
    @completed_investments = completed_investments_paginated
    authorize @completed_investments.first

    respond_to do |format|
      format.js  { completed_investments_path }
      format.html
    end
  end

  def active_index
    @active_investments =  active_investments_paginated
    authorize @active_investments.first

    respond_to do |format|
      format.js  { active_investments_path }
      format.html
    end
  end

  def reject
    authorize @investment
    @investment.reject!
    redirect_to investment_path(@investment)
  end

  def new
    @investment = Investment.new
    @investment.project = Project.new
    @investment.organisation = current_user.organisation
    @investment.installments << Installment.new(task:t("form.investment.installment.sub_task"), deadline: Date.today, investment: @investment, amount: 10)
    authorize @investment
  end

  def create
    simplified_params(investment_params)

    #Checks if user is trying to create a new organisation
    if @organisation_attributes.present?

      #find_by charity number if it already exists in the DB
      if Organisation.find_by(charity_number: @organisation_attributes[:charity_number]).present?
        organisation = Organisation.find_by(charity_number: @organisation_attributes[:charity_number])

      #else create it
      else
        organisation = Organisation.create(name: @organisation_attributes[:name], charity_number: @organisation_attributes[:charity_number])
        byebug

        if organisation.save
          organisation
        else
          new
          flash[:alert] = "Not saved due to new Org. Issues"
          render :new
          return
        end
      end

    #Checks if user is selecting existing organisation and returns it
    elsif @project_attributes[:organisation_id].present?
      organisation = Organisation.find(@project_attributes[:organisation_id])
    #Else renders new
    else
      new
      flash[:alert] = "Not saved due to NOTHING Org. Issues"
      render :new
      return
    end

    byebug
    #Checks for InvestmentTag and pushes them on the investment
    tags = []

    #Checks if tag exist already and adds to array
    if @investment_tag_ids.present?
      noEmptyTags = @investment_tag_ids.reject { |c| c.empty? }
      noEmptyTags.each {|tag_id| tags << InvestmentTag.find(tag_id)}
    end

    #Checks if tag exist already and adds to array
    if @investment_tag_attributes.present?
      @investment_tag_attributes.each {|_,value| tags << InvestmentTag.create!(name:value["name"]) }
    end

    project = Project.new(params.to_unsafe_h[:investment][:project_attributes])
    project.organisation = organisation
    @investment = Investment.new(investment_params)
    @investment.organisation = current_user.organisation
    @investment.project = project
    @investment.investment_tags.push(tags)
    authorize @investment

    if @investment.save && @investment.installments.count == 0
      @investment.installments << Installment.create!(task:t("form.investment.installment.sub_task"), deadline: Date.today, investment: @investment, amount: 0)
      flash[:notice] = "Investment successfully created"
      redirect_to investment_path(@investment)

    elsif @investment.save && @investment.installments.count > 0
      flash[:notice] = "Investment successfully created"
      redirect_to investment_path(@investment)

    else
      flash[:notice] = "Couldn't save!"
      render :new
    end
  end

  def edit
    @investment = selected_investment
    authorize @investment
  end

  def update
    investment = selected_investment
    authorize investment
    investment.update(investment_params)
    redirect_to investment_path(selected_investment)
    authorize @investment
  end

  def show
    @investment = Investment.find(id)
    authorize @investment
    #installments for project
        #amount for installment
        #task
        #time due
        #time left
        #total amount if all unlocked
        #currently gaved
  end

  def destroy
    authorize selected_investment
    selected_investment.destroy
    redirect_to investments_path
  end

  def unlocked_amount
    authorize selected_investment
    selected_investment.unlocked_amount

    render json: selected_investment.unlocked_amount
  end

  def to_csv
    authorize current_user.organisation.investments.first
    send_data Investment.to_csv(current_user.organisation), filename: "investments-#{Date.today.to_s}.csv", type: 'text/csv'
  end

  def generate_investments
    authorize current_user
    investments_csv = params[:investments_csv]
    investments_attributes = []
    CSV.foreach(investments_csv.path) do |investment|
      Investment.create!(email:user[0],password:user[1], organisation: current_user.organisation) unless user[0].split("@").count < 2
    end

    redirect_to downloads_path
  end

  private

  def active_investments_paginated
    Kaminari.paginate_array(current_user.organisation.active_investments.sort_by{|i| i.next_installment&.days_left}).page(params[:active_page]).per(10)
  end

  def completed_investments_paginated
    Kaminari.paginate_array(current_user.organisation.completed_investments).page(params[:completed_page]).per(10)
  end

  def rejected_investments_paginated
    Kaminari.paginate_array(current_user.organisation.rejected_investments).page(params[:completed_page]).per(10)
  end

  def id
    params[:id]
  end

  def selected_investment
    @investment= Investment.find(params[:id])
  end

  def investment_params
    params
      .require(:investment).permit(
        :project_id,
        { :investment_tag_ids => [] },
        installments_attributes: Installment.attribute_names.map(&:to_sym).push(:_destroy),
        project_attributes: [:name,:description,:focus_area_id,:main_contact,{ :geo_ids => [] }, :organisation_id, {organisation_attributes: Organisation.attribute_names.map(&:to_sym).push(:_destroy)},:_destroy],
        investment_tag_attributes: InvestmentTag.attribute_names.map(&:to_sym).push(:_destroy))
  end

  def simplified_params (params)
    params[:project_attributes][:organisation_attributes].present? ? @organisation_attributes = params[:project_attributes][:organisation_attributes] : @organisation_attributes = nil
    params[:project_attributes].present? ? @project_attributes = params[:project_attributes] : @project_attributes = nil
    params[:investment_tag_attributes].present? ? @investment_tag_attributes = params[:investment_tag_attributes] : @investment_tag_attributes = nil
    params[:investment_tag_ids].present? ? @investment_tag_ids = params[:investment_tag_ids] : @investment_tag_ids = nil
  end
end
