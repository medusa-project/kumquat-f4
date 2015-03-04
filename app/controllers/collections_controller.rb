class Array
  attr_accessor :total_length
end

class CollectionsController < ApplicationController

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    # TODO: search over fields other than title
    query = !params[:q].blank? ? "dc_title:#{params[:q]}" : nil
    @collections = Collection.where(query).order(:dc_title).start(@start).
        limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_shown = [@limit, @collections.total_length].min
  end

  def show
    @collection = Collection.find_by_web_id(params[:web_id])
    render text: '404 Not Found', status: 404 unless @collection
  end

end
