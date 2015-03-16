class LandingController < WebsiteController

  ##
  # Responds to GET /
  #
  def index
    # get a random image item to show
    @random_item = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'image/*').
        facet(false).order("random_#{SecureRandom.hex}").first
  end

end
