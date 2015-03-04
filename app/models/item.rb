class Item < Entity

  RESOURCE_TYPE = Fedora::ResourceType::ITEM

  attr_accessor :collection

  def initialize(params = {})
    @children = []
    super(params)
  end

  def ==(other)
    other.kind_of?(Item) and self.uuid == other.uuid
  end

  ##
  # @return array of Items
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

end
