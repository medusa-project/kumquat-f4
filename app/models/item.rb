class Item

  extend ActiveModel::Naming
  extend Forwardable
  delegate [:fedora_json_ld, :fedora_url, :triples, :uuid, :web_id] =>
               :fedora_container

  @@http = HTTPClient.new

  attr_reader :children
  attr_reader :fedora_container
  attr_accessor :solr_representation

  ##
  # @param uri Fedora resource URI
  # @return Item
  #
  def self.find(uri)
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
    response = solr.get('select', params: { q: "web_id:#{web_id}" })
    record = response['response']['docs'].first
    item = nil
    if record
      item = Item.find(record['id'])
      if item
        item.solr_representation = record
      end
    end
    item
  end

  def children
    self.fedora_container.children.each{ |c| @children << Item.new(c) } unless
        @children.any?
    @children
  end

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  def initialize(fedora_container)
    @children = []
    @fedora_container = fedora_container
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

end
