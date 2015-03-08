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

  ##
  # Overrides parent
  #
  # @return ActiveKumquat::SparqlUpdate
  #
  def to_sparql_update
    update = super
    update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
    # key
    update.delete('?s', '<kumquat:collectionKey>', '?o').
        insert(nil, 'kumquat:collectionKey', self.key)
    # resource type
    update.delete('?s', '<kumquat:resourceType>', '?o').
        insert(nil, 'kumquat:resourceType', ENTITY_TYPE)
  end

end
