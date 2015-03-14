class Array
  attr_accessor :total_length
end

class CollectionsController < ApplicationController

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    query = !params[:q].blank? ? "kq_searchall:#{params[:q]}" : nil
    #@collections = Collection.where(query).order(:kq_title).start(@start).
    #    limit(@limit)
    # TODO: find a way to re-enable sorting
    @collections = Collection.where(query).start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_shown = [@limit, @collections.total_length].min
  end

  def show
    @collection = Collection.find_by_web_id(params[:web_id])
    raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection
  end

end
