class ItemsController < WebsiteController

  class BrowseContext
    BROWSING_ALL_ITEMS = 0
    BROWSING_COLLECTION = 1
    SEARCHING = 2
    FAVORITES = 3
  end

  before_action :set_browse_context, only: :index

  ##
  # Redirects to an item's master bytestream in the repository.
  #
  # Responds to GET /items/:web_id/master
  #
  def master_bytestream
    @item = Repository::Item.find_by_web_id(params[:repository_item_web_id])
    raise ActiveRecord::RecordNotFound, 'Item not found' unless @item

    bs = @item.master_bytestream
    if bs and bs.public_repository_url
      redirect_to bs.public_repository_url
    else
      render text: '404 Not Found', status: 404
    end
  end

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)
    @items = Repository::Item.all.
        where("-#{Solr::Solr::PARENT_URI_KEY}:[* TO *]").
        where(params[:q])
    if params[:fq].respond_to?(:each)
      params[:fq].each { |fq| @items = @items.facet(fq) }
    else
      @items = @items.facet(params[:fq])
    end
    if params[:repository_collection_key]
      @collection = Repository::Collection.find_by_key(params[:repository_collection_key])
      raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection
      @items = @items.where(Solr::Solr::COLLECTION_KEY_KEY => @collection.key)
    end
    #@items = @items.order(:kq_title).start(@start).limit(@limit)
    # TODO: find a way to re-enable sorting
    @items = @items.start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_results_shown = [@limit, @items.total_length].min
  end

  def show
    @item = Repository::Item.find_by_web_id(params[:web_id])
    raise ActiveRecord::RecordNotFound, 'Collection not found' unless @item

    uri = repository_item_url(@item)
    respond_to do |format|
      format.html {}
      format.jsonld { render text: @item.public_rdf_graph(uri).to_jsonld }
      format.rdf { render text: @item.public_rdf_graph(uri).to_rdfxml }
      format.ttl { render text: @item.public_rdf_graph(uri).to_ttl }
    end
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
    elsif !params[:repository_collection_key]
      session[:browse_context] = BrowseContext::BROWSING_ALL_ITEMS
    else
      session[:browse_context] = BrowseContext::BROWSING_COLLECTION
    end
  end

end
