class CollectionsController < WebsiteController

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)
    query = !params[:q].blank? ? "#{Solr::Fields::SEARCH_ALL}:#{params[:q]}" : nil
    @collections = Repository::Collection.where(query).
        where(Solr::Fields::PUBLISHED => true).
        order(Solr::Fields::SINGLE_TITLE).start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_shown = [@limit, @collections.total_length].min
  end

  def show
    begin
      @collection = Repository::Collection.find_by_key(params[:key])
    rescue ActiveMedusa::RepositoryError => e
      render text: '410 Gone', status: 410 if e.res.code == 410
      @skip_after_actions = true
      return
    end
    raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection

    # Get a random image item to show. Limit to displayable media types.
    media_types = Derivable::DERIVABLE_IMAGE_TYPES.join(' OR ')
    @item = @collection.items.
        where("#{Solr::Fields::MEDIA_TYPE}:(#{media_types})").
        facet(false).order("random_#{SecureRandom.hex}").limit(1).first
  end

end
