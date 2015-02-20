class ItemsController < ApplicationController

  def index
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    response = solr.get('select', params: { :q => '*:*' })

    @items = []
    f4 = Fedora4.new
    response['response']['docs'].each do |doc|
      @items << f4.item(doc['id'])
    end
  end

  def show
    # look up the item by its UUID in Solr to get its Fedora URL
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config['solr_url'])
    response = solr.get('select', params: { :q => "uuid:#{params[:uuid]}" })
    doc = response['response']['docs'].first

    # get the item from Fedora
    f4 = Fedora4.new
    @item = f4.item(doc['id'])
  end

end
