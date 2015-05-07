class CollectionsController < WebsiteController

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)
    query = !params[:q].blank? ? "kq_searchall:#{params[:q]}" : nil
    @collections = Repository::Collection.where(query).
        where(Solr::Solr::PUBLISHED_KEY => true).
        order(Solr::Solr::SINGLE_TITLE_KEY).start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_shown = [@limit, @collections.total_length].min
  end

  def show
    begin
      @collection = Repository::Collection.find_by_key(params[:key])
    rescue HTTPClient::BadResponseError => e
      render text: '410 Gone', status: 410 if e.res.code == 410
      @skip_after_actions = true
      return
    end
    raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection

    # Get a random image item to show. Limit to certain common media types to
    # be safe.
    media_types = "(#{Repository::Bytestream::derivable_image_types.join(' OR ')})"
    @item = Repository::Item.
        where(Solr::Solr::COLLECTION_KEY_KEY => @collection.key).
        where(Solr::Solr::MEDIA_TYPE_KEY => media_types).
        facet(false).order("random_#{SecureRandom.hex}").first
  end

end
