class Array
  attr_accessor :total_length
end

class ItemsController < ApplicationController

  class BrowseContext
    BROWSE_ALL_ITEMS = 0
    BROWSE_COLLECTION = 1
    SEARCH = 2
  end

  before_action :set_browse_context, only: :index

  ##
  # Responds to GET /items/:web_id/bytestream
  #
  def bytestream
    item = Item.find_by_web_id(params[:item_web_id])
    redirect_to item.children.first.fedora_url # TODO: improve logic
  end

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    @start = params[:start] ? params[:start].to_i : 0
    base_query = "kq_resource_type:#{Fedora::ResourceType::ITEM} AND -kq_parent_uuid:[* TO *]"
    if params[:collection_web_id]
      @collection = Collection.find_by_web_id(params[:collection_web_id])
      base_query += " AND kq_collection_key:#{@collection.web_id}"
    end
    # TODO: search over fields other than title
    user_query = "dc_title:#{params[:q]} AND #{base_query}"
    response = solr.get('select', params: {
                                    q: !params[:q].blank? ? user_query : base_query,
                                    df: 'dc_title',
                                    start: @start,
                                    rows: @limit })
    @num_results_shown = response['response']['docs'].length
    @items = response['response']['docs'].map do |doc|
      item = Item.find(doc['id'])
      item.solr_representation = doc.to_s
      item
    end
    @items.total_length = response['response']['numFound'].to_i
    @current_page = (@start / @limit.to_f).ceil + 1
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
      session[:browse_context] = BrowseContext::SEARCH
    elsif params[:collection_web_id]
      session[:browse_context] = BrowseContext::BROWSE_COLLECTION
    else
      session[:browse_context] = BrowseContext::BROWSE_ALL_ITEMS
    end
  end

end
