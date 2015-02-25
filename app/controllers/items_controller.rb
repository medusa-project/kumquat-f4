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
    limit = Kumquat::Application.kumquat_config[:results_per_page]
    response = solr.get('select', params: {
                                    q: params[:q] ? params[:q] : '*:*',
                                    start: params[:start] ? params[:start] : 0,
                                    rows: limit })
    @num_results_shown = response['response']['docs'].length
    @num_results_total = response['response']['numFound'].to_i
    @items = response['response']['docs'].map do |doc|
      item = Item.find(doc['id'])
      item.solr_representation = doc.to_s
      item
    end
  end

  def show
    @item = Item.find_by_uuid(params[:uuid])
  end

end
