class Item < Entity

  ENTITY_TYPE = Entity::Type::ITEM

  attr_accessor :collection
  attr_accessor :page_index
  attr_accessor :parent_uuid

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
  # @return Item
  #
  def parent
    unless @parent
      uuid = self.solr_representation['kq_parent_uuid']
      @parent = Item.find_by_uuid(uuid) if uuid
    end
    @parent
  end

  protected

  def graph_outgoing_to_f4
    graph = super
    subject = RDF::URI(self.fedora_metadata_url)

    # collectionKey
    s = RDF::Statement.new(
        subject, RDF::URI("#{Entity::NAMESPACE_URI}collectionKey"),
        self.collection.key)
    replace_statement(graph, s)

    # parentUUID
    if self.parent_uuid
      s = RDF::Statement.new(
          subject, RDF::URI("#{Entity::NAMESPACE_URI}parentUUID"),
          self.parent_uuid)
      replace_statement(graph, s)
    end

    # pageIndex
    unless self.page_index.nil?
      s = RDF::Statement.new(
          subject, RDF::URI("#{Entity::NAMESPACE_URI}pageIndex"),
          self.page_index)
      replace_statement(graph, s)
    end

    # resourceType
    s = RDF::Statement.new(
        subject, RDF::URI("#{Entity::NAMESPACE_URI}resourceType"), ENTITY_TYPE)
    replace_statement(graph, s)

    graph
  end

end
