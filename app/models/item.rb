class Item < ActiveKumquat::Base

  include BytestreamOwner
  include ImageServing

  ENTITY_TYPE = ActiveKumquat::Base::Type::ITEM

  attr_accessor :collection
  attr_accessor :full_text
  attr_accessor :page_index
  attr_accessor :parent_uuid

  validates :title, length: { minimum: 2, maximum: 200 }

  def initialize(params = {})
    @children = []
    super(params)
  end

  def ==(other)
    other.kind_of?(Item) and self.uuid == other.uuid
  end

  ##
  # @return ActiveKumquat::Entity
  #
  def children
    @children = Item.all.where(Solr::Solr::PARENT_UUID_KEY => self.uuid).
        order(Solr::Solr::PAGE_INDEX_KEY) unless @children.any?
    @children
  end

  ##
  # @return Collection
  #
  def collection
    @collection = Collection.find_by_web_id(@collection_key) unless @collection
    @collection
  end

  ##
  # @return Item
  #
  def parent
    unless @parent
      self.fedora_graph.each_statement do |s|
        if s.predicate.to_s == Kumquat::Application::NAMESPACE_URI +
            Fedora::Repository::LocalTriples::PARENT_UUID
          @parent = Item.find_by_uuid(s.object.to_s)
          break
        end
      end
    end
    @parent
  end

  def to_s
    self.title || self.web_id
  end

  ##
  # Overrides parent
  #
  # @param graph RDF::Graph
  #
  def populate_from_graph(graph)
    super(graph)

    ns_uri = Kumquat::Application::NAMESPACE_URI
    local_triples = Fedora::Repository::LocalTriples

    graph.each_triple do |subject, predicate, object|
      case predicate
        when ns_uri + local_triples::COLLECTION_KEY
          @collection_key = object.to_s
        when ns_uri + local_triples::FULL_TEXT
         self.full_text = object.to_s
        when ns_uri + local_triples::PAGE_INDEX
          self.page_index = object.to_s
        when ns_uri + local_triples::PARENT_UUID
          self.parent_uuid = object.to_s
      end
    end
  end

  ##
  # Overrides parent
  #
  # @return ActiveKumquat::SparqlUpdate
  #
  def to_sparql_update
    update = super

    local_triples = Fedora::Repository::LocalTriples

    update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
    # collection key
    update.delete('<>', "<kumquat:#{local_triples::COLLECTION_KEY}>", '?o', false).
        insert(nil, "kumquat:#{local_triples::COLLECTION_KEY}", self.collection.key)
    # full text
    update.delete('<>', "<kumquat:#{local_triples::FULL_TEXT}>", '?o', false).
        insert(nil, "kumquat:#{local_triples::FULL_TEXT}", self.full_text) unless
        self.full_text.blank?
    # page index
    update.delete('<>', "<kumquat:#{local_triples::PAGE_INDEX}>", '?o', false)
    update.insert(nil, "kumquat:#{local_triples::PAGE_INDEX}", self.page_index) unless
        self.page_index.blank?
    # parent uuid
    update.delete('<>', "<kumquat:#{local_triples::PARENT_UUID}>", '?o', false)
    update.insert(nil, "kumquat:#{local_triples::PARENT_UUID}", self.parent_uuid) unless
        self.parent_uuid.blank?
    # resource type
    update.delete('<>', "<kumquat:#{local_triples::RESOURCE_TYPE}>", '?o', false).
        insert(nil, "kumquat:#{local_triples::RESOURCE_TYPE}", ENTITY_TYPE)
  end

end
