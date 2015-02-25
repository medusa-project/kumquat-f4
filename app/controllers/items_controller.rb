class ItemsController < ApplicationController

  ##
  # Responds to GET /items/:uuid/bytestream
  #
  def bytestream
    record = solr_record_by_uuid(params[:item_uuid])
    if record
      item = Item.find(record['id'])
      redirect_to item.children.first.fedora_url
    end
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
    # look up the item by its UUID in Solr to get its Fedora URL
    solr_record = solr_record_by_uuid(params[:uuid])
    f4_url = solr_record['id']

    # get the item from Fedora
    @item = Item.find(f4_url)
    @item.solr_representation = solr_record.to_s
  end

  private

  ##
  # Gets an item's Solr record.
  #
  # @return hash
  #
  def solr_record_by_uuid(uuid)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    response = solr.get('select', params: { q: "uuid:#{uuid}" })
    response['response']['docs'].first
  end

end
