class Collection < Entity

  RESOURCE_TYPE = Fedora::ResourceType::COLLECTION

  include Introspection

  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }

  def initialize(params = {})
    @items = []
    super(params)
  end

  def items
    unless @items.any?
      self.fedora_container.items.each do |c|
        item = Item.new(fedora_container: c)
        item.collection = self
        @items << item
      end
    end
    @items
  end

  def num_items
    @num_items = Item.where(kq_collection_key: self.web_id).
        where('-kq_parent_uuid:[* TO *]').count unless @num_items
    @num_items
  end

  def to_param
    self.web_id
  end

end
