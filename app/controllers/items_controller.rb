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
    @items = Repository::Item.where("-#{Solr::Fields::ITEM}:[* TO *]").
        where(params[:q])
    if params[:fq].respond_to?(:each)
      params[:fq].each { |fq| @items = @items.facet(fq) }
    else
      @items = @items.facet(params[:fq])
    end
    if params[:repository_collection_key]
      @collection = Repository::Collection.find_by_key(params[:repository_collection_key])
      raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection
      @items = @items.where(Solr::Fields::COLLECTION => @collection.repository_url)
    end
    # if there is no user-entered query, sort by title. Otherwise, use the
    # default sort, which is by relevance
    @items = @items.order(Solr::Fields::SINGLE_TITLE) if params[:q].blank?
    @items = @items.start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_results_shown = [@limit, @items.total_length].min

    respond_to do |format|
      format.html do
        # if there are no results, get some suggestions
        if @items.total_length < 1 and params[:q].present?
          @suggestions = Solr::Solr.new.suggestions(params[:q])
        end
      end
      format.jsonld do
        render text: RDFWriter.new(@items, :jsonld, request.url, request.host,
                                   request.port).to_s
      end
      format.rdfxml do
        render text: RDFWriter.new(@items, :rdfxml, request.url, request.host,
                                   request.port).to_s
      end
      format.ttl do
        render text: RDFWriter.new(@items, :ttl, request.url, request.host,
                                   request.port).to_s
      end
    end
  end

  def show
    begin
      @item = Repository::Item.find_by_web_id(params[:web_id])
    rescue HTTPClient::BadResponseError => e
      render text: '410 Gone', status: 410 if e.res.code == 410
      @skip_after_actions = true
      return
    end
    raise ActiveRecord::RecordNotFound, 'Item not found' unless @item

    uri = repository_item_url(@item)
    respond_to do |format|
      format.html do
        @pages = @item.parent_item.kind_of?(Repository::Item) ?
            @item.parent_item.items : @item.items
      end
      format.jsonld { render text: @item.public_rdf_graph(uri).to_jsonld }
      format.rdfxml { render text: @item.public_rdf_graph(uri).to_rdfxml }
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
