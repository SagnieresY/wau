class OrganisationsController < ApplicationController
  skip_after_action :verify_authorized

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      @organisation
    else
      render :new
    end
  end

  def search
    @output = {results:[]}
    ngos = Project.all.map(&:organisation).map(&:name).uniq
    Organisation.search_by_name(params[:query]).uniq.each_with_index do |organisation, i|
      if ngos.include?(organisation.name)
        @output[:results].push(organisation.name)
      end
    end
    render json: @output
  end

  def organisation_params
    params.require(:organisation).permit(:name,:charity_number)
  end
end
