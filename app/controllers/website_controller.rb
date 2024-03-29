##
# Base controller for all controllers related to the public website.
#
class WebsiteController < ApplicationController

  before_action :prepend_view_paths

  def setup
    super
    @num_items = Repository::Item.count
    @num_audios = Repository::Item.
        where("{!join from=#{Solr::Fields::ITEM} to=#{Solr::Fields::ID}}#{Solr::Fields::MEDIA_TYPE}:audio/*").
        omit_entity_query(true).facet(false).limit(1).count
    @num_images = Repository::Item.
        where("{!join from=#{Solr::Fields::ITEM} to=#{Solr::Fields::ID}}#{Solr::Fields::MEDIA_TYPE}:image/*").
        omit_entity_query(true).facet(false).limit(1).count
    @num_videos = Repository::Item.
        where("{!join from=#{Solr::Fields::ITEM} to=#{Solr::Fields::ID}}#{Solr::Fields::MEDIA_TYPE}:video/*").
        omit_entity_query(true).facet(false).limit(1).count

    # data for the nav bar search
    @collections = Repository::Collection.all
    @predicates_for_select = Triple.order(:label).
        map{ |p| [ p.label, p.solr_field ] }.uniq
    @predicates_for_select.unshift([ 'Any Field', Solr::Fields::SEARCH_ALL ])
  end

  private

  ##
  # Allow view templates to be overridden by adding custom templates to
  # /local/themes/[theme name]/views.
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
      theme ||= Theme.default
      pathname = nil
      pathname = File.join(Rails.root, theme.pathname, 'views') if theme
      prepend_view_path(pathname) if pathname
    end
  end

end
