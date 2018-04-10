class GeosController < ApplicationController
  skip_after_action :verify_authorized
  def search
    @geos = {results:[]}
    Geo.search_by_name(params[:query]).uniq.each_with_index do |geos, i|
      @geos[:results].push(geos.name)
    end
    @geos[:results] = @geos[:results].uniq
    render json: @geos
  end
end
