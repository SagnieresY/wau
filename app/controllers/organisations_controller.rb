class OrganisationsController < ApplicationController
  skip_after_action :verify_authorized

  def search
    @output = {results:[]}
    ngos = Project.all.map(&:organisation).map(&:name).uniq
    Organisation.search_by_name(params[:query]).each_with_index do |organisation, i|
      if ngos.include?(organisation.name)
        @output[:results].push(organisation.name)
      end
    end
    render json: @output
  end
end
