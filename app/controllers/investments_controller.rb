class InvestmentsController < ApplicationController
  def index
    authorize @investment
  end

  def new
    authorize @investment
  end

  def create
    authorize @investment
  end

  def edit
    authorize @investment
  end

  def update
    authorize @investment
  end

  def show
    authorize @investment
  end

  def destroy
    authorize @investment
  end
end
