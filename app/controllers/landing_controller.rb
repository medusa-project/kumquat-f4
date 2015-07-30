class LandingController < WebsiteController

  ##
  # Responds to GET /
  #
  def index
    # Get a random image item to show. Limit to known displayable media types.
    media_types = "(#{Derivable::DERIVABLE_IMAGE_TYPES.join(' OR ')})"
    @random_item = Repository::Item.
        where("#{Solr::Fields::MEDIA_TYPE}:#{media_types}").
        facet(false).order("random_#{SecureRandom.hex}").limit(1).first
  end

end
