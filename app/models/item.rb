class Item < Entity

  extend ActiveModel::Naming
  extend Forwardable
  delegate [:fedora_json_ld, :fedora_url, :triples, :uuid, :web_id] =>
               :fedora_container

  @@http = HTTPClient.new

  attr_reader :children
  attr_accessor :collection
  attr_reader :fedora_container
  attr_accessor :solr_representation

  ##
  # @param uri Fedora resource URI
  # @return Item
  #
  def self.find(uri) # TODO: rename to find_by_uri
    Item.new(Fedora::Container.find(uri))
  end

  ##
  # @param uuid string
  # @return Item
  #
  def self.find_by_uuid(uuid)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    response = solr.get('select', params: { q: "uuid:#{uuid}" })
    record = response['response']['docs'].first
    item = Item.find(record['id'])
    item.solr_representation = record
    item
  end

  ##
  # @param web_id string
  # @return Item
  #
  def self.find_by_web_id(web_id)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    response = solr.get('select', params: { q: "kq_web_id:#{web_id}" })
    record = response['response']['docs'].first
    item = nil
    if record
      item = Item.find(record['id'])
      item.solr_representation = record if item
    end
    item
  end

  ##
  # @param fedora_container Fedora::Container
  #
  def initialize(fedora_container)
    @children = []
    @fedora_container = fedora_container
  end

  def ==(other)
    other.kind_of?(Item) and (self.uuid == other.uuid)
  end

  ##
  # @return array of Items
  #
  def children
    unless @children.any?
      solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
      response = solr.get('select', params: { q: "kq_parent_uuid:#{self.uuid}",
                                              sort: 'kq_page_index asc' })
      response['response']['docs'].each do |doc|
        item = Item.find(doc['id'])
        item.solr_representation = doc
        @children << item
      end
    end
    @children
  end

  ##
  # @return Collection
  #
  def collection
    unless @collection
      @collection = Collection.find_by_web_id(
          self.solr_representation['kq_collection_key'])
    end
    @collection
  end

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  ##
  # @return Item
  #
  def parent
    unless @parent
      uuid = self.solr_representation['kq_parent_uuid']
      @parent = Item.find_by_uuid(uuid) if uuid
    end
    @parent
  end

  def persisted?
    !self.fedora_container.nil?
  end

  def to_model
    self
  end

  def to_param
    self.web_id
  end

  def save
    self.fedora_container.save
    # TODO: save associated dirty entities (bytestreams, collection)
  end

  # TODO: get rid of this
  def subtitle
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/terms/alternative')
    end
    t.first ? t.first.value : nil
  end

  ##
  # @see subtitle
  #
  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : 'Untitled'
  end

  def triple(predicate)
    t = self.triples.select do |e|
      e.predicate.include?(predicate)
    end
    t.first ? t.first.value : nil
  end

end
