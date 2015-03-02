class Array
  attr_accessor :total_length
end

class CollectionsController < ApplicationController

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    @start = params[:start] ? params[:start].to_i : 0
    base_query = "resource_type:#{Fedora::ResourceType::COLLECTION}"
    # TODO: search over fields other than title
    user_query = "dc_title:#{params[:q]} AND #{base_query}"
    response = solr.get('select', params: {
                                    q: !params[:q].blank? ? user_query : base_query,
                                    df: 'dc_title',
                                    start: @start,
                                    sort: 'dc_title asc',
                                    rows: @limit })
    @num_results_shown = response['response']['docs'].length
    @collections = response['response']['docs'].map do |doc|
      item = Collection.find(doc['id'])
      item.solr_representation = doc.to_s
      item
    end
    @collections.total_length = response['response']['numFound'].to_i
    @current_page = (@start / @limit.to_f).ceil + 1
  end

  def show
    @collection = Collection.find_by_web_id(params[:web_id])
    render text: '404 Not Found', status: 404 unless @collection
  end

end
