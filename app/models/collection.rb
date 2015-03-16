class Collection < ActiveKumquat::Base

  include Introspection

  ENTITY_TYPE = ActiveKumquat::Base::Type::COLLECTION

  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }
  validates :title, length: { minimum: 2, maximum: 200 }

  before_delete :delete_derivatives

  ##
  # Convenience method that deletes a collection with the given key.
  #
  # @param key
  #
  def self.delete_with_key(key)
    root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
    col_to_delete = ::Collection.new(
        repository_url: "#{root_container_url.chomp('/')}/#{key}",
        key: key)
    col_to_delete.delete(true)
  end

  ##
  # Deletes the static images of all items in the collection.
  #
  # @raise RuntimeError
  #
  def delete_derivatives
    if self.key
      FileUtils.rm_rf(File.join(DerivativeManagement::DERIVATIVE_ROOT, self.key))
    else
      raise 'Cannot delete the static images of a collection with a nil key.'
    end
  end

  def num_items
    @num_items = Item.where(Solr::Solr::COLLECTION_KEY_KEY => self.key).
        where("-#{Solr::Solr::PARENT_UUID_KEY}:[* TO *]").count unless @num_items
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

  def to_s
    self.title || self.key
  end

  ##
  # Overrides parent
  #
  # @return ActiveKumquat::SparqlUpdate
  #
  def to_sparql_update
    update = super
    local_triples = Fedora::Repository::LocalTriples
    update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
    # key
    update.delete('<>', "<kumquat:#{local_triples::COLLECTION_KEY}>", '?o', false).
        insert(nil, "kumquat:#{local_triples::COLLECTION_KEY}", self.key)
    # resource type
    update.delete('<>', "<kumquat:#{local_triples::RESOURCE_TYPE}>", '?o', false).
        insert(nil, "kumquat:#{local_triples::RESOURCE_TYPE}", ENTITY_TYPE)
  end

end
