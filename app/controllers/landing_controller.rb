class LandingController < WebsiteController

  ##
  # Responds to GET /
  #
  def index
    # Get a random image item to show. Limit to certain common media types to
    # be safe.
    media_types = "(#{Repository::Bytestream::derivable_image_types.join(' OR ')})"
    @random_item = Repository::Item.
        where(Solr::Solr::MEDIA_TYPE_KEY => media_types).
        facet(false).order("random_#{SecureRandom.hex}").first
  end

end
