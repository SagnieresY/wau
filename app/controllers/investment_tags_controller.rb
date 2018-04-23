class InvestmentTagsController < ApplicationController
  before_action :authenticate_user!
  before_action :selected_investment_tag, only: [:edit, :update, :destroy, :unlock, :rescind ]

  after_action :verify_authorized, :except => :index, unless: :devise_controller?
  after_action :verify_policy_scoped, :only => :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @investment_tags = policy_scope(current_user.organisation.investment_tags.all).order(created_at: :desc)
  end

  def new
    @investment_tag = InvestmentTag.new
    authorize @investment_tag
  end

  def create
    @investment_tag = InvestmentTag.new(investment_tag_params)
    @investment_tag.organisation = current_user.organisation
    authorize @investment_tag

    if @investment_tag.save
      flash[:notice] = "Your investment tag was successfully created"
      redirect_to investment_tags_path
    else
      flash[:warning] = "Sorry, the investment tag was not saved"
      redirect_to investment_tags_path
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

  def investment_tag_params
    params.require(:investment_tag)
          .permit(
            :name,
            :organisation_id,
            :investment_id)
  end

  def find_investment
    @investment = Investment.find(params[:investment_id])
  end

  def find_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def selected_investment_tag
    @investment_tag = InvestmentTag.find(params[:id])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end
end
