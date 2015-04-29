module Admin

  class ItemsController < ControlPanelController

    def destroy
      @item = Repository::Item.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @item

      command = DeleteItemCommand.new(@item)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
        redirect_to admin_repository_item_url(@item)
      else
        flash['success'] = "Item \"#{@item.title}\" deleted."
        redirect_to admin_repository_item_url
      end
    end

    def index
      @start = params[:start] ? params[:start].to_i : 0
      @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)
      @items = Repository::Item.all.
          where("-#{Solr::Solr::PARENT_URI_KEY}:[* TO *]").
          where(params[:q])
      if params[:repository_collection_key]
        @collection = Repository::Collection.find_by_key(params[:repository_collection_key])
        raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection
        @items = @items.where(Solr::Solr::COLLECTION_KEY_KEY => @collection.key)
      end
      @items = @items.start(@start).limit(@limit)
      @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
      @num_results_shown = [@limit, @items.total_length].min

      # these are used by the search form
      @predicates_for_select = DB::RDFPredicate.order(:uri).
          map{ |p| [ p.uri, p.solr_field ] }.uniq
      @predicates_for_select.unshift([ 'Any Triple', 'kq_searchall' ])

      @collections = Repository::Collection.all
    end

    ##
    # Responds to POST /search. Translates the input from the advanced search
    # form into a query string compatible with index(), and 302-redirects to
    # it.
    #
    def search
      where_clauses = []

      # fields
      if params[:triples] and params[:triples].any?
        params[:triples].each_with_index do |field, index|
          if params[:terms].length > index and !params[:terms][index].blank?
            where_clauses << "#{field}:#{params[:terms][index]}"
          end
        end
      end

      # collections
      keys = []
      keys = params[:keys].select{ |k| !k.blank? } if params[:keys].any?
      if keys.any? and keys.length < Repository::Collection.all.length
        where_clauses << "#{Solr::Solr::COLLECTION_KEY_KEY}:(#{keys.join(' ')})"
      end

      redirect_to admin_repository_items_path(q: where_clauses.join(' AND '))
    end

    def show
      @item = Repository::Item.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @item

      uri = repository_item_url(@item)
      respond_to do |format|
        format.html { @pages = @item.parent ? @item.parent.children : @item.children}
        format.jsonld { render text: @item.admin_rdf_graph(uri).to_jsonld }
        format.rdf { render text: @item.admin_rdf_graph(uri).to_rdfxml }
        format.ttl { render text: @item.admin_rdf_graph(uri).to_ttl }
      end
    end

  end

end
