class InvestmentTagsController < ApplicationController
  
  before_action :selected_investment_tag, only: [:edit, :update, :destroy, :unlock, :rescind ]
  before_action :find_investment, only: [:create, :new, :edit, :update, :destroy]
  before_action :find_organisation, only: [:create, :new, :edit, :update, :destroy]

  def new
    @investment_tag = InvestmentTag.new
    authorize @investment
  end

  def create
    @investment_tag = InvestmentTag.new(investment_tag_params)
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
end
