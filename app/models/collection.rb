class Collection < ActiveKumquat::Base

  include Introspection

  ENTITY_TYPE = ActiveKumquat::Base::Type::COLLECTION

  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }

  def num_items
    @num_items = Item.where(kq_collection_key: self.key).
        where('-kq_parent_uuid:[* TO *]').count unless @num_items
    @num_items
  end

  ##
  # @param graph RDF::Graph
  #
  def populate_from_graph(graph)
    super(graph)
    graph.each_triple do |subject, predicate, object|
      if predicate == "#{Kumquat::Application::NAMESPACE_URI}collectionKey"
        self.key = object.to_s
      end
    end
  end

  def populate_into_graph(in_graph)
    out_graph = super(in_graph)
    subject = RDF::URI(self.fedora_metadata_url)

    # collectionKey
    s = RDF::Statement.new(
        subject, RDF::URI("#{Kumquat::Application::NAMESPACE_URI}collectionKey"),
        self.key)
    replace_statement(out_graph, s)

    # resourceType
    s = RDF::Statement.new(
        subject, RDF::URI("#{Kumquat::Application::NAMESPACE_URI}resourceType"),
        ENTITY_TYPE)
    replace_statement(out_graph, s)

    out_graph
  end

end
