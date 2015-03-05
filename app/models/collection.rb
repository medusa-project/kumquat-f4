class Collection < Entity

  include Introspection

  ENTITY_TYPE = Entity::Type::COLLECTION

  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }

  def num_items
    @num_items = Item.where(kq_collection_key: self.web_id).
        where('-kq_parent_uuid:[* TO *]').count unless @num_items
    @num_items
  end

end
