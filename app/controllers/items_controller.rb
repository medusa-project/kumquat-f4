class Array
  attr_accessor :total_length
end

class ItemsController < ApplicationController

  ##
  # Responds to GET /items/:uuid/bytestream
  #
  def bytestream
    item = Container.find_by_uuid(params[:item_uuid])
    redirect_to item.children.first.fedora_url # TODO: improve logic
  end

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    @limit = Kumquat::Application.kumquat_config[:results_per_page]
    @start = params[:start] ? params[:start].to_i : 0
    response = solr.get('select', params: {
                                    q: params[:q] ? params[:q] : '*:*',
                                    df: 'dc_title',
                                    start: @start,
                                    rows: @limit })
    @num_results_shown = response['response']['docs'].length
    @items = response['response']['docs'].map do |doc|
      item = Item.find(doc['id'])
      item.solr_representation = doc.to_s
      item
    end
    @items.total_length = response['response']['numFound'].to_i
    @current_page = (@start / @limit.to_f).ceil + 1
  end

  def show
    @item = Item.find_by_web_id(params[:web_id])
    render text: '404 Not Found', status: 404 unless @item
  end

end
