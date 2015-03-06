class Collection < Entity

  include Introspection

  ENTITY_TYPE = Entity::Type::COLLECTION

  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }

  def num_items
    @num_items = Item.where(kq_collection_key: self.key).
        where('-kq_parent_uuid:[* TO *]').count unless @num_items
    @num_items
  end

  protected

  def graph_outgoing_to_f4
    graph = super
    subject = RDF::URI(self.fedora_metadata_url)

    # collectionKey
    s = RDF::Statement.new(
        subject, RDF::URI("#{Entity::NAMESPACE_URI}collectionKey"), self.key)
    replace_statement(graph, s)

    # resourceType
    s = RDF::Statement.new(
        subject, RDF::URI("#{Entity::NAMESPACE_URI}resourceType"), ENTITY_TYPE)
    replace_statement(graph, s)

    graph
  end

end
