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
    end

    def show
      @item = Repository::Item.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @item
      @pages = @item.parent ? @item.parent.children : @item.children
    end

  end

end
