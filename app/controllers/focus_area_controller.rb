class FocusAreaController < ApplicationController
   skip_after_action :verify_authorized
   def search
    @focus_areas = {results:[]}
    FocusArea.search_by_name(params[:query]).uniq.each_with_index do |focus, i|
      @focus_areas[:results].push(focus.name)
    end
    render json: @focus_areas
   end
end
