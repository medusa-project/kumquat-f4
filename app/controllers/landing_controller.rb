class LandingController < WebsiteController

  ##
  # Responds to GET /
  #
  def index
    # Get a random image item to show. Limit to known displayable media types.
    media_types = Repository::Bytestream::derivable_image_types.join(' OR ')
    @random_item = Repository::Item.
        where("{!join from=#{Solr::Fields::ITEM} to=#{Solr::Fields::ID}}#{Solr::Fields::MEDIA_TYPE}:(#{media_types})").
        omit_entity_query(true).
        facet(false).order("random_#{SecureRandom.hex}").limit(1).first
  end

end
