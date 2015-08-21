module Repository

  class Collection < ActiveMedusa::Container

    include ActiveMedusa::Indexable
    include Describable
    include Introspection

    entity_class_uri 'http://pcdm.org/models#Collection'

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
          repository_url: "#{root_container_url.chomp('/')}/#{key}", # TODO: this is not reliable
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
            DB::Collection.create!(key: self.key,
                                   metadata_profile: MetadataProfile.find_by_default(true))
      end
      @db_counterpart
    end

    def num_items
      @num_items = Repository::Item.
          where(Solr::Fields::COLLECTION => self.repository_url).
          where("-#{Solr::Fields::ITEM}:[* TO *]").count unless @num_items
      @num_items
    end

    ##
    # Overrides ActiveMedusa::Indexable.solr_document
    #
    def solr_document
      doc = super
      doc[Solr::Fields::SINGLE_TITLE] = self.title
      doc[Solr::Fields::CREATED_AT] =
          self.rdf_graph.any_object('http://fedora.info/definitions/v4/repository#created').to_s
      doc[Solr::Fields::UPDATED_AT] =
          self.rdf_graph.any_object('http://fedora.info/definitions/v4/repository#lastModified').to_s

      # add arbitrary triples from the instance's rdf_graph, excluding
      # property/association/repo-managed triples
      exclude_predicates = Repository::Fedora::MANAGED_PREDICATES
      exclude_predicates += self.class.properties.
          select{ |p| p.class == self.class }.map(&:rdf_predicate)
      exclude_predicates += self.class.associations.
          select{ |a| a.class == self.class and
          a.type == Association::Type::BELONGS_TO }.map(&:rdf_predicate)
      exclude_predicates += ['http://fedora.info/definitions/v4/repository#created',
                             'http://fedora.info/definitions/v4/repository#lastModified']

      self.rdf_graph.each_statement do |st|
        pred = st.predicate.to_s
        obj = st.object.to_s
        unless exclude_predicates.include?(pred)
          doc[Solr::Solr::field_name_for_predicate(pred)] = obj
        end
      end

      doc
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
