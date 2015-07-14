module Repository

  class Collection < ActiveMedusa::Container

    include Describable
    include Indexable
    include Introspection

    entity_class_uri Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::COLLECTION

    has_many :items, class_name: 'Repository::Item'

    property :key,
             type: :string,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::COLLECTION_KEY,
             solr_field: Solr::Fields::COLLECTION_KEY
    property :published,
             type: :boolean,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::PUBLISHED,
             solr_field: Solr::Fields::PUBLISHED

    validates :key, length: { minimum: 2, maximum: 20 }
    #validates :title, length: { minimum: 2, maximum: 200 }

    # TODO: this is a workaround for after_destroy not working
    after_save :delete_db_counterpart

    ##
    # Convenience method that deletes a collection with the given key.
    #
    # @param key [String]
    # @param transaction_url string
    #
    def self.delete_with_key(key, transaction_url = nil)
      root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      col_to_delete = Repository::Collection.new(
          repository_url: "#{root_container_url.chomp('/')}/#{key}",
          key: key,
          transaction_url: transaction_url)
      col_to_delete.delete(also_tombstone: true)
    end

    ##
    # @param key [String]
    # @return [Repository::Collection]
    #
    def self.find_by_key(key)
      self.where(Solr::Fields::COLLECTION_KEY => key).first rescue nil
    end

    ##
    # @return [DB::Collection]
    #
    def db_counterpart
      unless @db_counterpart
        @db_counterpart = DB::Collection.find_by_key(self.key) ||
            DB::Collection.create!(key: self.key)
      end
      @db_counterpart
    end

    def num_items
      @num_items = Repository::Item.
          where(Solr::Fields::COLLECTION => self.repository_url).
          where("-#{Solr::Fields::ITEM}:[* TO *]").count unless @num_items
      @num_items
    end

    def reindex
      kq_predicates = Kumquat::RDFPredicates

      doc = base_solr_document
      doc[Solr::Fields::COLLECTION_KEY] =
          self.rdf_graph.any_object(kq_predicates::COLLECTION_KEY)
      doc[Solr::Fields::PUBLISHED] =
          self.rdf_graph.any_object(kq_predicates::PUBLISHED)
      doc[Solr::Fields::SINGLE_TITLE] = self.title

      Solr::Solr.client.add(doc)
    end

    def to_param
      self.key
    end

    def to_s
      self.title || self.key
    end

    private

    ##
    # Deletes the corresponding database model.
    #
    def delete_db_counterpart
      if self.destroyed?
        db_cp = db_counterpart
        db_cp.destroy! if db_cp
      end
    end

  end

end
