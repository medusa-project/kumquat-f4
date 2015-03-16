class Item < ActiveKumquat::Base

  include BytestreamOwner
  include DerivativeManagement
  include ImageServing

  ENTITY_CLASS = ActiveKumquat::Base::Class::ITEM

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
            Fedora::Repository::LocalPredicates::PARENT_UUID
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
    local_predicates = Fedora::Repository::LocalPredicates

    graph.each_triple do |subject, predicate, object|
      case predicate
        when ns_uri + local_predicates::COLLECTION_KEY
          @collection_key = object.to_s
        when ns_uri + local_predicates::FULL_TEXT
         self.full_text = object.to_s
        when ns_uri + local_predicates::PAGE_INDEX
          self.page_index = object.to_s
        when ns_uri + local_predicates::PARENT_UUID
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
    k_uri = Kumquat::Application::NAMESPACE_URI
    local_predicates = Fedora::Repository::LocalPredicates
    local_objects = Fedora::Repository::LocalObjects

    update = super
    update.prefix('kumquat', k_uri)
    # collection key
    update.delete('<>', "<kumquat:#{local_predicates::COLLECTION_KEY}>", '?o', false).
        insert(nil, "kumquat:#{local_predicates::COLLECTION_KEY}", self.collection.key)
    # full text
    update.delete('<>', "<kumquat:#{local_predicates::FULL_TEXT}>", '?o', false).
        insert(nil, "kumquat:#{local_predicates::FULL_TEXT}", self.full_text) unless
        self.full_text.blank?
    # page index
    update.delete('<>', "<kumquat:#{local_predicates::PAGE_INDEX}>", '?o', false)
    update.insert(nil, "kumquat:#{local_predicates::PAGE_INDEX}", self.page_index) unless
        self.page_index.blank?
    # parent uuid
    update.delete('<>', "<kumquat:#{local_predicates::PARENT_UUID}>", '?o', false)
    update.insert(nil, "kumquat:#{local_predicates::PARENT_UUID}", self.parent_uuid) unless
        self.parent_uuid.blank?
    # resource type
    update.delete('<>', "<kumquat:#{local_predicates::CLASS}>", '?o', false).
        insert(nil, "kumquat:#{local_predicates::CLASS}", "<#{k_uri}#{local_objects::ITEM}>", false)
  end

end
