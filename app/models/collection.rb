class Collection

  extend ActiveModel::Naming
  extend Forwardable
  delegate [:fedora_json_ld, :fedora_url, :triples, :uuid, :web_id] =>
               :fedora_container

  @@http = HTTPClient.new

  attr_reader :items
  attr_reader :fedora_container
  attr_accessor :solr_representation

  ##
  # @param uri Fedora resource URI
  # @return Collection
  #
  def self.find(uri)
    Collection.new(Fedora::Container.find(uri))
  end

  ##
  # @param uuid string
  # @return Collection
  #
  def self.find_by_uuid(uuid)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    response = solr.get('select', params: { q: "uuid:#{uuid}" })
    record = response['response']['docs'].first
    item = Collection.find(record['id'])
    item.solr_representation = record
    item
  end

  ##
  # @param web_id string
  # @return Collection
  #
  def self.find_by_web_id(web_id)
    solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
    response = solr.get('select', params: { q: "kq_web_id:#{web_id}" })
    record = response['response']['docs'].first
    collection = nil
    if record
      collection = Collection.find(record['id'])
      if collection
        collection.solr_representation = record
      end
    end
    collection
  end

  def items
    self.fedora_container.items.each{ |c| @items << Item.new(c) } unless
        @items.any?
    @items
  end

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  def initialize(fedora_container)
    @children = []
    @fedora_container = fedora_container
  end

  def num_items
    unless @num_items
      solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
      query = "kq_collection_key:#{self.web_id}"
      response = solr.get('select', params: { q: query, start: 0, rows: 0 })
      @num_items = response['response']['numFound']
    end
    @num_items
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
  end

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
