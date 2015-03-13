class Item < ActiveKumquat::Base

  include BytestreamOwner
  include ImageServing

  ENTITY_TYPE = ActiveKumquat::Base::Type::ITEM

  attr_accessor :collection
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
    @collection = Collection.find_by_web_id(collection_key) unless @collection
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
  # @return ActiveKumquat::SparqlUpdate
  #
  def to_sparql_update
    update = super
    update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
    # collection key
    update.delete('<>', '<kumquat:collectionKey>', '?o', false).
        insert(nil, 'kumquat:collectionKey', self.collection.key)
    # page index
    update.delete('<>', '<kumquat:pageIndex>', '?o', false)
    update.insert(nil, 'kumquat:pageIndex', self.page_index) if self.page_index
    # parent uuid
    update.delete('<>', '<kumquat:parentUUID>', '?o', false)
    update.insert(nil, 'kumquat:parentUUID', self.parent_uuid) if
        self.parent_uuid
    # resource type
    update.delete('<>', '<kumquat:resourceType>', '?o', false).
        insert(nil, 'kumquat:resourceType', ENTITY_TYPE)
  end

  private

  def collection_key
    self.fedora_graph.each_statement do |s|
      return s.object.to_s if s.predicate.to_s == Kumquat::Application::NAMESPACE_URI +
          Fedora::Repository::LocalTriples::COLLECTION_KEY
    end
    nil
  end

end
