class WebsiteController < ApplicationController

  after_action :prepend_view_paths

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
    unless @skip_after_actions
      key = 'default'
      if params[:key]
        key = params[:key]
      elsif params[:repository_collection_key]
        key = params[:repository_collection_key]
      elsif params[:web_id]
        item = Repository::Item.find_by_web_id(params[:web_id])
        raise ActiveRecord::RecordNotFound unless item
        key = item.collection.key
      end

      theme = nil
      collection = DB::Collection.find_by_key(key)
      theme = collection.theme if collection
      theme ||= DB::Theme.default
      pathname = nil
      pathname = File.join(Rails.root, theme.pathname, 'views') if theme
      prepend_view_path(pathname) if pathname
    end
  end

end
