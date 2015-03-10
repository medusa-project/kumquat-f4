class Array
  attr_accessor :total_length
end

class ItemsController < ApplicationController

  class BrowseContext
    BROWSING_ALL_ITEMS = 0
    BROWSING_COLLECTION = 1
    SEARCHING = 2
  end

  before_action :set_browse_context, only: :index

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    @items = Item.all.where("-#{Solr::Solr::PARENT_UUID_KEY}:[* TO *]").
        where(params[:q])
    if params[:collection_web_id]
      @collection = Collection.find_by_web_id(params[:collection_web_id])
      @items = @items.where(Solr::Solr::COLLECTION_KEY_KEY => @collection.web_id)
    end
    #@items = @items.order(:kq_title).start(@start).limit(@limit)
    # TODO: find a way to re-enable sorting
    @items = @items.start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_results_shown = [@limit, @items.total_length].min
  end

  def show
    @item = Item.find_by_web_id(params[:web_id])
    render text: '404 Not Found', status: 404 unless @item
  end

  private

  ##
  # The browse context is "what the user is doing" -- necessary information in
  # item view in which we need to know the "mode of entry" in order to display
  # appropriate navigational controls, either "back to results" or "back to
  # collection" etc.
  #
  def set_browse_context
    session[:browse_context_url] = request.url
    if !params[:q].blank?
      session[:browse_context] = BrowseContext::SEARCHING
    elsif !params[:collection_web_id]
      session[:browse_context] = BrowseContext::BROWSING_ALL_ITEMS
    else
      session[:browse_context] = BrowseContext::BROWSING_COLLECTION
    end
  end

end
