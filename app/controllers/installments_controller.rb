class InstallmentsController < ApplicationController

  before_action :selected_installment, only: [:edit, :update, :destroy, :unlock, :rescind ]
  before_action :find_investment, only: [:create, :new, :edit, :update, :destroy]


  def new
    @installment = Installment.new
    authorize @investment
  end

  def create
    @installment = Installment.new(installment_params)

    @installment.investment = @investment
    authorize @investment
    if @installment.save
      redirect_to investment_path(@investment)
    else
      render :new
      #redirect_to new_investment_installment_path(@installment)
    end
  end

  def edit
    authorize @installment
    authorize @investment
    @investment.completed?
  end

  def update
    authorize @installment
    @installment.update!(installment_params)
    @installment.save!
    @installment.investment.completed?
    puts installment_params
    redirect_to investment_path(@investment)
  end

  def destroy
    authorize @installment
    @installment.destroy
    redirect_to investment_path(@investment)
  end

  def unlock
    authorize @installment
    @investment = @installment.investment
    @installment.unlock!
    @investment.update_status
    @investment.completed? #check if investment is completed

    # render json: {
    #   installment: @installment,
    #   stats: @installment.investment.unlocked_amount
    # }
    @page = params[:page]
    if @page == "home"
      # reset_global_variables
      t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
      @year = t.year

      #prepares installments for charts
      @unlocked_installments = current_user.organisation.unlocked_installments
      @locked_installments = current_user.organisation.locked_installments

      @unlocked_installments = current_user.organisation.unlocked_installments
      @locked_installments = current_user.organisation.locked_installments

      locked_hash = @locked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)
      unlocked_hash = @unlocked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)

      locked_hash.keys.each { |k| locked_hash[FocusArea.find(k).name] = locked_hash.delete(k) }
      @locked_installments_fa_chart = locked_hash

      unlocked_hash.keys.each { |k| unlocked_hash[FocusArea.find(k).name] = unlocked_hash.delete(k) }
      @unlocked_installments_fa_chart = unlocked_hash

      respond_to do |format|
        format.html { unlock_installment_path }
        format.js
      end

    elsif @page == "show"
      respond_to do |format|
        format.html { unlock_installment_path }
        format.js
      end

    else
      respond_to do |format|
        format.html { render 'investment/show'}
        format.js
      end
    end
  end

  def lock
    authorize @installment
    @installment.lock!
    @investment = @installment.investment
  end

  def rescind
    #only way to rescind installment
    authorize @installment
    @investment = @installment.investment
    @installment.rescind!
    @investment.update_status
    @investment.completed? #check if investment is completed

    @page = params[:page]
    if true
      # reset_global_variables
      t = Time.new(Time.now.year,1,1,0,0,0,'+00:00')
      @year = t.year

      #prepares installments for charts
      @unlocked_installments = current_user.organisation.unlocked_installments
      @locked_installments = current_user.organisation.locked_installments

      locked_hash = @locked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)
      unlocked_hash = @unlocked_installments.joins(:focus_area).group('focus_areas.id').sum(:amount)

      locked_hash.keys.each { |k| locked_hash[FocusArea.find(k).name] = locked_hash.delete(k) }
      @locked_installments_fa_chart = locked_hash

      unlocked_hash.keys.each { |k| unlocked_hash[FocusArea.find(k).name] = unlocked_hash.delete(k) }
      @unlocked_installments_fa_chart = unlocked_hash

      respond_to do |format|
        format.html { rescind_installment_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'investment/show'}
        format.js
      end
    end
  end

  private

  def installment_params
    params.require(:installment).permit(:task,:amount,:deadline, :id, :status)
  end

  def find_investment
    @investment = Investment.find(params[:investment_id])
  end

  def selected_installment
    @installment = Installment.find(params[:id])
  end
end
