module Repository

  class Collection < ActiveKumquat::Base

    include Introspection

    ENTITY_CLASS = ActiveKumquat::Base::Class::COLLECTION # TODO: get rid of this

    attr_accessor :key

    validates :key, length: { minimum: 2, maximum: 20 }
    validates :title, length: { minimum: 2, maximum: 200 }

    after_delete :delete_db_counterpart

    ##
    # Convenience method that deletes a collection with the given key.
    #
    # @param key
    #
    def self.delete_with_key(key)
      root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      col_to_delete = Repository::Collection.new(
          repository_url: "#{root_container_url.chomp('/')}/#{key}",
          key: key)
      col_to_delete.delete(true)
    end

    ##
    # @param key string
    # @return Entity
    #
    def self.find_by_key(key)
      self.where(Solr::Solr::COLLECTION_KEY_KEY => key).first
    end

    ##
    # @return DB::Collection
    ##
    def db_counterpart
      unless @db_counterpart
        @db_counterpart = DB::Collection.find_by_key(self.key)
        @db_counterpart = DB::Collection.create!(key: self.key) unless
            @db_counterpart
      end
      @db_counterpart
    end

    def num_items
      @num_items = Repository::Item.
          where(Solr::Solr::COLLECTION_KEY_KEY => self.key).
          where("-#{Solr::Solr::PARENT_URI_KEY}:[* TO *]").count unless @num_items
      @num_items
    end

    ##
    # @param graph RDF::Graph
    #
    def populate_from_graph(graph)
      super(graph)
      graph.each_triple do |subject, predicate, object|
        if predicate == Kumquat::Application::NAMESPACE_URI +
            Kumquat::Application::RDFPredicates::COLLECTION_KEY
          self.key = object.to_s
        end
      end
    end

    def to_param
      self.key
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
      kq_uri = Kumquat::Application::NAMESPACE_URI
      kq_predicates = Kumquat::Application::RDFPredicates
      kq_objects = Kumquat::Application::RDFObjects

      update = super
      update.prefix('kumquat', kq_uri)
      # key
      update.delete('<>', "<kumquat:#{kq_predicates::COLLECTION_KEY}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::COLLECTION_KEY}", self.key)
      # resource type
      update.delete('<>', "<kumquat:#{kq_predicates::CLASS}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::CLASS}",
                 "<#{kq_uri}#{kq_objects::COLLECTION}>", false)
    end

    private

    ##
    # Deletes the corresponding database model.
    #
    def delete_db_counterpart
      db_cp = db_counterpart
      db_cp.destroy! if db_cp
    end

  end

end
