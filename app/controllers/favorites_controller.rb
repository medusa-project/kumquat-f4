class FavoritesController < WebsiteController

  include ActionView::Helpers::TextHelper

  COOKIE_DELIMITER = ','

  before_action :set_browse_context, only: :index

  def create
    @item = Item.find_by_web_id(params[:web_id])
    raise ActiveRecord::RecordNotFound, 'Item not found' unless @item

    favorites = cookies[:favorites] || ''
    cookies[:favorites] = favorites.split(COOKIE_DELIMITER).
        push(@item.web_id).uniq.join(COOKIE_DELIMITER)

    flash['success'] = "\"#{truncate(@item.title, length: 50)}\" has been "\
    "added to your favorites."
    redirect_to :back
  end

  def destroy
    @item = Item.find_by_web_id(params[:web_id])
    raise ActiveRecord::RecordNotFound, 'Item not found' unless @item

    unless cookies[:favorites].blank?
      cookies[:favorites] = cookies[:favorites].split(COOKIE_DELIMITER).
          reject{ |f| f == @item.web_id }.join(COOKIE_DELIMITER)
      flash['success'] = "\"#{truncate(@item.title, length: 50)}\" has been "\
      "removed from your favorites."
    end
    redirect_to :back
  end

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Kumquat::Application.kumquat_config[:results_per_page]

    @items = Item.none

    unless cookies[:favorites].blank?
      web_id_length = Kumquat::Application.kumquat_config[:web_id_length]
      web_ids = cookies[:favorites].split(COOKIE_DELIMITER).
          select{ |f| f.length == web_id_length }
      if web_ids.any?
        @items = Item.where("#{Solr::Solr::WEB_ID_KEY}:(#{web_ids.map{ |id| "#{id}" }.join(' ')})")
      end
    end

    @items = @items.start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_results_shown = [@limit, @items.total_length].min
  end

  private

  ##
  # See ItemsController.set_browse_context for documentation.
  #
  def set_browse_context
    session[:browse_context_url] = request.url
    session[:browse_context] = ItemsController::BrowseContext::FAVORITES
  end

end
