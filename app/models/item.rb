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
      uuid = self.solr_json[Solr::Solr::PARENT_UUID_KEY.to_s]
      @parent = Item.find_by_uuid(uuid) if uuid
    end
    @parent
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
    update.delete('?s', '<kumquat:collectionKey>', '?o').
        insert(nil, 'kumquat:collectionKey', self.collection.key)
    # page index
    update.delete('?s', '<kumquat:pageIndex>', '?o')
    update.insert(nil, 'kumquat:pageIndex', self.page_index) if self.page_index
    # parent uuid
    update.delete('?s', '<kumquat:parentUUID>', '?o')
    update.insert(nil, 'kumquat:parentUUID', self.parent_uuid) if
        self.parent_uuid
    # resource type
    update.delete('?s', '<kumquat:resourceType>', '?o').
        insert(nil, 'kumquat:resourceType', ENTITY_TYPE)
  end

  private

  def collection_key
    if self.solr_json
      self.solr_json[Solr::Solr::COLLECTION_KEY_KEY.to_s]
    end
    nil
  end

end
