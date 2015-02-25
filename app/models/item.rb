class Item

  extend ActiveModel::Naming
  extend Forwardable
  delegate [:fedora_json_ld, :fedora_url, :triples, :uuid] => :fedora_container

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

  def children
    self.fedora_container.children.each{ |c| @children << Item.new(c) } unless
        @children.any?
    @children
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
    self.uuid
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
