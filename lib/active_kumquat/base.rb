module ActiveKumquat

  ##
  # Abstract class from which several Kumquat entities inherit. This class
  # supports containers, i.e. Fedora resources whose bodies consist of linked
  # data; NOT binary resources, for which the Bytestream class exists instead.
  #
  class Base

    include ActiveModel::Model
    include Describable

    class Type
      BYTESTREAM = 'bytestream'
      COLLECTION = 'collection'
      ITEM = 'item'
    end

    WEB_ID_LENGTH = 5

    @@http = HTTPClient.new
    @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

    attr_reader :bytestreams # Set of Bytestreams
    attr_accessor :container_url # URL of the entity's parent container
    attr_accessor :fedora_graph # RDF::Graph
    attr_accessor :fedora_url
    attr_accessor :requested_slug # requested F4 last path component for new entities
    attr_accessor :solr_json
    attr_accessor :uuid
    alias_method :id, :uuid
    attr_accessor :web_id

    validates_presence_of :web_id
    validates :uuid, allow_nil: true, length: { minimum: 36, maximum: 36 }

    ##
    # @return ActiveKumquat::Entity
    #
    def self.all
      ActiveKumquat::Entity.new(self)
    end

    ##
    # @param id UUID
    # @return Entity
    #
    def self.find(id)
      self.find_by_uuid(id)
    end

    ##
    # @param uri Fedora resource URI
    # @return Entity
    #
    def self.find_by_uri(uri)
      self.where(id: uri).first
    end

    ##
    # @param uuid string
    # @return Entity
    #
    def self.find_by_uuid(uuid)
      self.where(uuid: uuid).first
    end

    ##
    # @param web_id string
    # @return Entity
    #
    def self.find_by_web_id(web_id)
      self.where(Solr::Solr::WEB_ID_KEY => web_id).first
    end

    def self.method_missing(name, *args, &block)
      if [:count, :first, :limit, :order, :start, :where].include?(name.to_sym)
        ActiveKumquat::Entity.new(self).send(name, *args, &block)
      end
    end

    def self.respond_to_missing?(method_name, include_private = false)
      [:first, :limit, :order, :start, :where].include?(method_name.to_sym)
    end

    def initialize(params = {})
      @bytestreams = Set.new
      @destroyed = false
      @persisted = false
      @triples = []
      params.except(:id, :uuid).each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    ##
    # @param also_tombstone boolean
    # @param commit_immediately boolean
    #
    def delete(also_tombstone = false, commit_immediately = true)
      if self.fedora_url
        url = self.fedora_url.chomp('/')
        @@http.delete(url)
        @@http.delete("#{url}/fcr:tombstone") if also_tombstone
        @destroyed = true
        @persisted = false

        if commit_immediately
          # wait for solr to get the delete from fcrepo-message-consumer
          # TODO: this is horrible
          # (also doing this in save())
          sleep 2
          @@solr.commit
        end
      end
    end

    alias_method :destroy, :delete
    alias_method :destroy!, :delete

    def destroyed?
      @destroyed
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
      graph.each_triple do |subject, predicate, object|
        if predicate == 'http://fedora.info/definitions/v4/repository#uuid'
          self.uuid = object.to_s
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}webID"
          self.web_id = object.to_s
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}hasMasterBytestream"
          bs = Bytestream.new(owner: self, fedora_url: object.to_s)
          bs.reload!
          self.bytestreams << bs
        elsif predicate.to_s.include?('http://purl.org/dc/') and
            !object.to_s.include?('/fedora.info/')
          self.triples << Triple.new(predicate: predicate.to_s, object: object.to_s)
        end
      end
      @fedora_graph = graph
      @persisted = true
    end

    def reload!
      response = @@http.get(self.fedora_url, nil,
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
      elsif self.uuid
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
        @@solr.commit
        self.reload!
      end
    end

    alias_method :save!, :save

    def to_param
      self.web_id
    end

    ##
    # Generates a SparqlUpdate with the instance's current properties.
    # Subclasses should override and add their own statements into the return
    # value of super.
    #
    # @return ActiveKumquat::SparqlUpdate
    #
    def to_sparql_update
      update = SparqlUpdate.new
      update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)

      _web_id = self.web_id.blank? ? generate_web_id : self.web_id
      update.delete('?s', '<kumquat:webID>', '?o', false).
          insert(nil, 'kumquat:webID', _web_id)
      update.prefix('indexing', 'http://fedora.info/definitions/v4/indexing#').
          delete('?s', '<indexing:hasIndexingTransformation>', '?o', false).
          insert(nil, 'indexing:hasIndexingTransformation',
                 Fedora::Repository::INDEXING_TRANSFORM_NAME)
      update.prefix('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
          delete('?s', '<rdf:type>', 'indexing:Indexable', false).
          insert(nil, 'rdf:type', 'indexing:Indexable', false)
      self.triples.each do |triple|
        update.delete('?s', "<#{triple.predicate}>", '?o', false).
            insert(nil, "<#{triple.predicate}>", triple.object)
      end
      update
    end

    def update(params)
      params.except(:id, :uuid).each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def update!(params)
      self.update(params)
      self.save!
    end

    private

    ##
    # Generates a guaranteed-unique web ID, of which there are
    # 36^WEB_ID_LENGTH available.
    #
    def generate_web_id
      proposed_id = nil
      while true
        proposed_id = (36 ** (WEB_ID_LENGTH - 1) +
            rand(36 ** WEB_ID_LENGTH - 36 ** (WEB_ID_LENGTH - 1))).to_s(36)
        break unless ActiveKumquat::Base.find_by_web_id(proposed_id)
      end
      proposed_id
    end

    ##
    # Updates an existing item.
    #
    def save_existing
      @@http.patch(self.fedora_url, self.to_sparql_update.to_s,
                   { 'Content-Type' => 'application/sparql-update' })
    end

    ##
    # Creates a new item.
    #
    def save_new
      # As of version 4.1, Fedora doesn't like to accept triples via POST for
      # some reason; it just returns 201 Created regardless of the Content-Type
      # header and body content. PUT works, though. So we will POST to create
      # an empty container, and then update that.

      # POST to create a new resource
      headers = { 'Content-Type' => 'application/n-triples' }
      headers['slug'] = self.requested_slug if self.requested_slug
      response = @@http.post(self.container_url, nil, headers)
      self.fedora_url = response.header['Location'].first
      self.requested_slug = nil

      save_existing
    end

  end

end
