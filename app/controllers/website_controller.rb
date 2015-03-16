class WebsiteController < ApplicationController

  before_filter :prepend_view_paths

  def setup
    super
    @num_items = Item.count
    @num_audios = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'audio/*').count
    @num_images = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'image/*').count
    @num_videos = Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'video/*').count
  end

  private

  ##
  # Allow users to override view templates by adding them to app/local/views.
  #
  def prepend_view_paths
    prepend_view_path('local/views')
  end

end
