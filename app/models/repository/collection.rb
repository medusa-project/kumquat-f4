module Repository

  class Collection < ActiveKumquat::Base

    include Introspection

    ENTITY_CLASS = ActiveKumquat::Base::Class::COLLECTION # TODO: get rid of this

    rdf_property :key, type: :string,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::COLLECTION_KEY
    rdf_property :published, type: :boolean,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::PUBLISHED
    rdf_property :resource_type, type: :uri,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::CLASS

    validates :key, length: { minimum: 2, maximum: 20 }
    validates :title, length: { minimum: 2, maximum: 200 }

    after_delete :delete_db_counterpart

    ##
    # Convenience method that deletes a collection with the given key.
    #
    # @param key
    # @param transaction_url string
    #
    def self.delete_with_key(key, transaction_url = nil)
      root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      col_to_delete = Repository::Collection.new(
          repository_url: "#{root_container_url.chomp('/')}/#{key}",
          key: key,
          transaction_url: transaction_url)
      col_to_delete.delete(true)
    end

    ##
    # @param key string
    # @param transaction_url string
    # @return Entity
    #
    def self.find_by_key(key, transaction_url = nil)
      self.where(Solr::Fields::COLLECTION_KEY => key).
          use_transaction_url(transaction_url).first rescue nil
    end

    def initialize(params = {})
      @resource_type = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::COLLECTION
      super(params)
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
          where(Solr::Fields::COLLECTION_KEY => self.key).
          where("-#{Solr::Fields::PARENT_URI}:[* TO *]").count unless @num_items
      @num_items
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
      db_cp = db_counterpart
      db_cp.destroy! if db_cp
    end

  end

end
