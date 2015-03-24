class WebsiteController < ApplicationController

  before_filter :prepend_view_paths

  def setup
    super
    @num_items = Repository::Item.count
    @num_audios = Repository::Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'audio/*').count
    @num_images = Repository::Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'image/*').count
    @num_videos = Repository::Item.where(Solr::Solr::MEDIA_TYPE_KEY => 'video/*').count
  end

  private

  ##
  # Allow users to override view templates by adding them to
  # /local/[theme name]/views.
  #
  def prepend_view_paths
    key = 'default'
    if params[:key]
      key = params[:key]
    elsif params[:repository_collection_key]
      key = params[:repository_collection_key]
    elsif params[:web_id]
      key = Repository::Item.find_by_web_id(params[:web_id]).collection.key
    end

    themes = Kumquat::Application.kumquat_config[:themes]
    if themes and themes.any?
      theme = themes[key.to_sym]
      if theme
        prepend_view_path("local/themes/#{theme}/views")
      elsif themes[:default]
        prepend_view_path("local/themes/#{themes[:default]}/views")
      end
    end
  end

end
