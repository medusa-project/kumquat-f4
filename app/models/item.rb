class Item < Entity

  ENTITY_TYPE = Entity::Type::ITEM

  attr_accessor :collection

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
    @children = Item.all.where(kq_parent_uuid: self.uuid).
        order(:kq_page_index) unless @children.any?
    @children
  end

  ##
  # @return Collection
  #
  def collection
    @collection = Collection.find_by_web_id(
        self.solr_representation['kq_collection_key']) unless @collection
    @collection
  end

  ##
  # Overrides parent to extract Item-specific metadata from the Fedora JSON-LD
  # representation.
  #
  # @param json JSON string
  # @return void
  #
  def fedora_json_ld=(json)
    super(json)
    struct = JSON.parse(json.force_encoding('UTF-8')).select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end
    if struct[0]["#{Entity::NAMESPACE_URI}parentUUID"]
      self.parent_uuid = struct[0]["#{Entity::NAMESPACE_URI}parentUUID"].
          first['@value']
    end
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

end
