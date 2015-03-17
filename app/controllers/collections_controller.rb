class Array
  attr_accessor :total_length
end

class CollectionsController < WebsiteController

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
    @collection = Collection.find_by_key(params[:key])
    raise ActiveRecord::RecordNotFound, 'Collection not found' unless @collection

    # get a random item to show
    @item = Item.where(Solr::Solr::COLLECTION_KEY_KEY => @collection.key).
        where(Solr::Solr::MEDIA_TYPE_KEY => 'image/*').
        facet(false).order("random_#{SecureRandom.hex}").first
  end

end
