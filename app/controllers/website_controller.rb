class WebsiteController < ApplicationController

  def setup
    super
    @num_items = Item.count
    @num_audios = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'audio/*').count
    @num_images = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'image/*').count
    @num_videos = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'video/*').count
  end

end
