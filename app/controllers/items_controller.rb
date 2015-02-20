class ItemsController < ApplicationController

  ##
  # Responds to GET /items/:uuid/bytestream
  #
  def bytestream
    f4 = Fedora4.new
    @item = f4.item(find_f4_url_by_uuid(params[:item_uuid]))
    redirect_to @item.bytestreams.first.fedora_uri
  end

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    response = solr.get('select', params: { :q => '*:*' })

    f4 = Fedora4.new
    @items = response['response']['docs'].map{ |doc| f4.item(doc['id']) }
  end

  def show
    # look up the item by its UUID in Solr to get its Fedora URL
    f4_url = find_f4_url_by_uuid(params[:uuid])

    # get the item from Fedora
    f4 = Fedora4.new
    @item = f4.item(f4_url)
  end

  private

  def find_f4_url_by_uuid(uuid)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    response = solr.get('select', params: { :q => "uuid:#{uuid}" })
    response['response']['docs'].first['id']
  end

end
