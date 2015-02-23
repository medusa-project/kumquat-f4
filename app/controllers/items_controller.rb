class ItemsController < ApplicationController

  ##
  # Responds to GET /items/:uuid/bytestream
  #
  def bytestream
    f4 = Fedora4.new
    @item = f4.item(find_item_by_uuid(params[:item_uuid]))
    redirect_to @item.bytestreams.first.fedora_uri
  end

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    limit = Kumquat::Application.kumquat_config['results_per_page']
    response = solr.get('select', params: {
                                    q: params[:q] ? params[:q] : '*:*',
                                    start: params[:start] ? params[:start] : 0,
                                    rows: limit })
    @num_results_shown = response['response']['docs'].length
    @num_results_total = response['response']['numFound'].to_i
    f4 = Fedora4.new
    @items = response['response']['docs'].map do |doc|
      item = f4.item(doc['id'])
      item.solr_representation = doc.to_s
      item
    end
  end

  def show
    # look up the item by its UUID in Solr to get its Fedora URL
    solr_record = find_item_by_uuid(params[:uuid])
    f4_url = solr_record['id']

    # get the item from Fedora
    f4 = Fedora4.new
    @item = f4.item(f4_url)
    @item.solr_representation = solr_record.to_s
  end

  private

  ##
  # Gets an item's Solr record.
  #
  # @return hash
  #
  def find_item_by_uuid(uuid)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    response = solr.get('select', params: { q: "uuid:#{uuid}" })
    response['response']['docs'].first
  end

end
