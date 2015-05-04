module ActiveKumquat

  ##
  # Abstract class from which several Kumquat entities inherit. This class
  # supports containers, i.e. Fedora resources whose bodies consist of linked
  # data; NOT binary resources, for which the Bytestream class exists instead.
  #
  class Base

    extend ActiveKumquat::Querying
    extend ActiveModel::Callbacks
    include ActiveModel::Model
    include Describable
    include GlobalID::Identification
    include Transactions

    define_model_callbacks :create, :delete, :load, :save, :update,
                           only: [:after, :before]

    class Class
      BYTESTREAM = 'Bytestream'
      COLLECTION = 'Collection'
      ITEM = 'Item'
    end

    @@http = HTTPClient.new
    @@kq_properties = Set.new

    attr_reader :bytestreams # Set of Bytestreams
    attr_accessor :container_url # URL of the entity's parent container
    attr_accessor :rdf_graph
    attr_accessor :repository_url # the entity's repository URL outside of any transaction
    attr_accessor :requested_slug # requested F4 last path component for new entities
    attr_accessor :solr_json
    attr_accessor :transaction_url
    attr_accessor :uuid
    alias_method :id, :uuid

    validates :uuid, allow_nil: true, length: { minimum: 36, maximum: 36 }

    ##
    # Supplies a "property" keyword to subclasses with which they define the
    # properties they want to persist to the repository. Example:
    #
    #     property :full_text, uri: 'http://example.org/fullText', type: :string
    #
    # @param name
    # @param options Hash with the following keys:
    #     :uri RDF predicate URI
    #     :type One of: :string, :integer, :boolean, :uri
    #
    def self.rdf_property(name, options)
      @@kq_properties << { class: self, name: name, uri: options[:uri],
                           type: options[:type] }
    end

    ##
    # Executes a block within a transaction. Use like:
    #
    # ActiveKumquat::Base.transaction do |transaction_url|
    #   (code to run within the transaction)
    # end
    #
    # See https://wiki.duraspace.org/display/FEDORA41/Transactions
    #
    # @param url Transaction base URL
    #
    def self.transaction
      url = create_transaction(@@http)
      begin
        yield url
      rescue => e
        rollback_transaction(url, @@http)
        raise e
      else
        commit_transaction(url, @@http)
      end
    end

    def initialize(params = {})
      @@kq_properties.each do |prop|
        self.class.instance_eval { attr_accessor prop[:name] }
      end
      @bytestreams = Set.new
      @destroyed = false
      @persisted = false
      @rdf_graph = RDF::Graph.new
      params.except(:id, :uuid).each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def created_at
      self.rdf_graph.each_statement do |statement|
        if statement.predicate.to_s == 'http://fedora.info/definitions/v4/repository#created'
          return Time.parse(statement.object.to_s)
        end
      end
      nil
    end

    ##
    # @param also_tombstone boolean
    # @param commit_immediately boolean
    #
    def delete(also_tombstone = false, commit_immediately = true)
      url = transactional_url(self.repository_url)
      if url
        run_callbacks :delete do
          url = url.chomp('/')
          @@http.delete(url)
          @@http.delete("#{url}/fcr:tombstone") if also_tombstone
          @destroyed = true
          @persisted = false

          if commit_immediately
            # wait for solr to get the delete from fcrepo-message-consumer
            # TODO: this is horrible
            # (also doing this in save())
            sleep 2
            Solr::Solr.client.commit
          end
        end
      end
    end

    alias_method :destroy, :delete
    alias_method :destroy!, :delete

    def destroyed?
      @destroyed
    end

    def loaded=(loaded)
      run_callbacks :load do
        # noop
      end
    end

    def persisted?
      @persisted and !@destroyed
    end

    ##
    # Populates the instance with data from an RDF graph.
    # Subclasses should override this (and call super) to populate their own
    # attributes from the graph received from F4.
    #
    # @param graph RDF::Graph
    #
    def populate_from_graph(graph)
      kq_uri = Kumquat::Application::NAMESPACE_URI
      kq_predicates = Kumquat::Application::RDFPredicates

      graph.each_statement do |statement|
        if statement.predicate == RDF::URI('http://fedora.info/definitions/v4/repository#uuid')
          self.uuid = statement.object.to_s
        elsif statement.predicate.to_s == kq_uri + kq_predicates::BYTESTREAM_URI
          bs = Repository::Bytestream.new(owner: self,
                                          repository_url: statement.object.to_s,
                                          transaction_url: self.transaction_url)
          bs.reload!
          self.bytestreams << bs
        end
        self.rdf_graph << statement
      end

      # add properties from subclass property definitions (see
      # self.rdf_property())
      @@kq_properties.select{ |p| p[:class] == self.class }.each do |prop|
        graph.each_triple do |subject, predicate, object|
          if predicate.to_s == prop[:uri]
            if prop[:type] == :boolean
              value = ['true', '1'].include?(object.to_s)
            else
              value = object.to_s
            end
            send("#{prop[:name]}=", value)
            break
          end
        end
      end

      @persisted = true
    end

    def reload!
      url = transactional_url(self.repository_url)
      response = @@http.get(url, nil,
                            { 'Accept' => 'application/n-triples' })
      graph = RDF::Graph.new
      graph.from_ntriples(response.body)
      self.populate_from_graph(graph)
    end

    ##
    # Persists the entity. For this to work, The entity must already have a
    # UUID (for existing entities) OR it must have a parent container URL (for
    # new entities).
    #
    # @param commit_immediately boolean
    # @raise RuntimeError
    #
    def save(commit_immediately = true) # TODO: look into Solr soft commits
      #raise 'Validation error' unless self.valid? TODO: uncomment this
      if self.destroyed?
        raise RuntimeError, 'Cannot save a destroyed object.'
      end
      run_callbacks :save do
        if self.uuid
          save_existing
        elsif self.container_url
          save_new
        else
          raise RuntimeError, 'UUID and container URL are both nil. One or the
          other is required.'
        end
        @persisted = true
        if commit_immediately
          # wait for solr to get the add from fcrepo-message-consumer
          # TODO: this is horrible (also doing it in delete())
          sleep 2
          Solr::Solr.client.commit
          self.reload!
        end
      end
    end

    alias_method :save!, :save

    ##
    # Generates a SparqlUpdate with the instance's current properties.
    #
    # @return ActiveKumquat::SparqlUpdate
    #
    def to_sparql_update
      update = SparqlUpdate.new
      update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
      update.prefix('indexing', 'http://fedora.info/definitions/v4/indexing#').
          delete('<>', '<indexing:hasIndexingTransformation>', '?o', false).
          insert(nil, 'indexing:hasIndexingTransformation',
                 Repository::Fedora::INDEXING_TRANSFORM_NAME)
      update.prefix('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
          delete('<>', '<rdf:type>', 'indexing:Indexable', false).
          insert(nil, 'rdf:type', 'indexing:Indexable', false)

      self.rdf_graph.each_statement do |statement|
        # exclude repository-managed predicates from the update
        next if Repository::Fedora::MANAGED_PREDICATES.
            select{ |p| statement.predicate.to_s.start_with?(p) }.any?
        # exclude subclass-managed predicates from the update
        next if @@kq_properties.select{ |p| p[:class] == self.class }.
            map{ |p| p[:uri] }.include?(statement.predicate.to_s)

        update.delete('<>', "<#{statement.predicate.to_s}>", '?o', false).
            insert(nil, "<#{statement.predicate.to_s}>",
                   statement.object.to_s)
      end

      # add properties from subclass property definitions (see self.property())
      @@kq_properties.select{ |p| p[:class] == self.class }.each do |prop|
        update.delete('<>', "<#{prop[:uri]}>", '?o', false)
        value = send(prop[:name])
        case prop[:type]
          when :boolean
            value = ['true', '1'].include?(value.to_s) ? 'true' : 'false'
            update.insert(nil, "<#{prop[:uri]}>", value)
          when :uri
            update.insert(nil, "<#{prop[:uri]}>", "<#{value}>", false) if
                value.present?
          else
            update.insert(nil, "<#{prop[:uri]}>", value) if value.present?
        end
      end

      update
    end

    def update(params)
      run_callbacks :update do
        params.except(:id, :uuid).each do |k, v|
          send("#{k}=", v) if respond_to?("#{k}=")
        end
      end
    end

    def update!(params)
      self.update(params)
      self.save!
    end

    def updated_at
      self.rdf_graph.each_statement do |statement|
        if statement.predicate.to_s == 'http://fedora.info/definitions/v4/repository#lastModified'
          return Time.parse(statement.object.to_s)
        end
      end
      nil
    end

    protected

    ##
    # Updates an existing item.
    #
    def save_existing
      url = transactional_url(self.repository_url)
      @@http.patch(url, self.to_sparql_update.to_s,
                   { 'Content-Type' => 'application/sparql-update' })
    end

    ##
    # Creates a new item.
    #
    def save_new
      run_callbacks :create do
        url = transactional_url(self.container_url)
        # As of version 4.1, Fedora doesn't like to accept triples via POST for
        # some reason; it just returns 201 Created regardless of the Content-Type
        # header and body content. So we will POST to create an empty container,
        # and then update that.
        headers = { 'Content-Type' => 'application/n-triples' }
        headers['slug'] = self.requested_slug if self.requested_slug
        response = @@http.post(url, nil, headers)
        self.repository_url = nontransactional_url(response.header['Location'].first)
        self.requested_slug = nil
        save_existing
      end
    end

  end

end
