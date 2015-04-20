class FavoritesController < WebsiteController

  include ActionView::Helpers::TextHelper

  COOKIE_DELIMITER = ','

  before_action :set_browse_context
  after_action :purge_invalid_favorites, only: :index

  def index
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)

    @items = Repository::Item.none

    unless cookies[:favorites].blank?
      web_ids = cookies[:favorites].split(COOKIE_DELIMITER)
      if web_ids.any?
        @items = Repository::Item.
            where("#{Solr::Solr::WEB_ID_KEY}:(#{web_ids.map{ |id| "#{id}" }.join(' ')})")
      end
    end

    @items = @items.start(@start).limit(@limit)
    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
    @num_results_shown = [@limit, @items.total_length].min
  end

  private

  ##
  # Rewrites the favorites cookie if there are any items in the cookie that
  # no longer exist in the repo.
  #
  def purge_invalid_favorites
    if cookies[:favorites]
      web_ids = cookies[:favorites].split(COOKIE_DELIMITER)
      if web_ids.length != @items.length
        cookies[:favorites] = @items.map(&:web_id).join(COOKIE_DELIMITER)
      end
    end
  end

  ##
  # See ItemsController.set_browse_context for documentation.
  #
  def set_browse_context
    session[:browse_context_url] = request.url
    session[:browse_context] = ItemsController::BrowseContext::FAVORITES
  end

end
