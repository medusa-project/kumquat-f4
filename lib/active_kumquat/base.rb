module ActiveKumquat

  ##
  # Abstract class from which several Kumquat entities inherit.
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

    attr_accessor :container_url # URL of the entity's parent container
    attr_accessor :fedora_graph # RDF::Graph
    attr_accessor :fedora_url
    attr_accessor :requested_slug # requested F4 last path component for new entities
    attr_accessor :solr_representation
    attr_accessor :uuid
    alias_method :id, :uuid
    attr_accessor :web_id

    validates :title, length: { minimum: 2, maximum: 200 }
    validates :uuid, length: { minimum: 36, maximum: 36 }
    validates_presence_of :web_id

    ##
    # @return ActiveKumquat::Entity
    #
    def self.all
      ActiveKumquat::Entity.new(self)
    end

    ##
    # @param uri Fedora resource URI
    # @return Entity
    #
    def self.find(uri) # TODO: rename to find_by_uri
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
      self.where(kq_web_id: web_id).first
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
      @destroyed = false
      @persisted = false
      @triples = []

      params.each do |k, v|
        if respond_to?("#{k}=")
          send "#{k}=", v
        else
          instance_variable_set "@#{k}", v
        end
      end
    end

    ##
    # @param also_tombstone boolean
    # @param commit_immediately boolean
    #
    def delete(also_tombstone = false, commit_immediately = true)
      url = self.fedora_url.chomp('/')
      @@http.delete(url)
      @@http.delete("#{url}/fcr:tombstone") if also_tombstone
      @destroyed = true
      @persisted = false

      if commit_immediately
        # wait for solr to get the delete from fcrepo-message-consumer
        # TODO: this is horrible; can we wait for a notification from solr?
        # (also doing this in save())
        sleep 2
        @@solr.commit
      end

    end

    alias_method :destroy, :delete
    alias_method :destroy!, :delete

    def reload!
      response = @@http.get(self.fedora_metadata_url, nil,
                            { 'Accept' => 'application/n-triples' })
      graph = RDF::Graph.new
      graph.from_ntriples(response.body)
      self.populate_from_graph(graph)
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
        if predicate == "#{Kumquat::Application::NAMESPACE_URI}webID"
          self.web_id = object.to_s
        elsif predicate == 'http://fedora.info/definitions/v4/repository#uuid'
          self.uuid = object.to_s
        elsif predicate.to_s.include?('http://purl.org/dc/')
          self.triples << Triple.new(predicate: predicate.to_s, object: object.to_s)
        end
      end
      @fedora_graph = graph
      @persisted = true
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
      if @destroyed
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
        # TODO: this is horrible; can we wait for a notification from solr?
        # (also doing this in delete())
        sleep 2
        @@solr.commit
      end
    end

    alias_method :save!, :save

    def to_param
      self.web_id
    end

    protected

    ##
    # Subclasses should override this (and call super) to populate their own
    # attributes into the graph to be sent to F4.
    #
    def populate_into_graph
      graph = RDF::Graph.new
      @fedora_graph.each_statement { |statement| graph << statement }

      subject = RDF::URI(self.fedora_metadata_url)
      statement = RDF::Statement.new(subject,
                                     RDF::URI("#{Kumquat::Application::NAMESPACE_URI}webID"),
                                     self.web_id ? self.web_id : generate_web_id)
      graph << statement unless graph.has_statement?(statement)

      self.triples.each do |triple|
        statement = RDF::Statement.new(subject, RDF::URI(triple.predicate),
                                       triple.object)
        replace_statement(graph, statement)
      end
      graph
    end

    def fedora_metadata_url
      "#{self.fedora_url.chomp('/')}/fcr:metadata"
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

    def make_indexable
      headers = { 'Content-Type' => 'application/sparql-update' }
      body = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
        'PREFIX indexing: <http://fedora.info/definitions/v4/indexing#> '\
        'DELETE { } '\
        'INSERT { '\
          "<> indexing:hasIndexingTransformation \"#{Fedora::Repository::INDEXING_TRANSFORM_NAME}\"; "\
          'rdf:type indexing:Indexable; } '\
        'WHERE { }'
      @@http.patch(self.fedora_metadata_url, body, headers)
    end

    ##
    # Updates an existing item.
    #
    def save_existing
      self.reload! # GET its representation in order to append triples to it
      # PUT it back
      @@http.put(self.fedora_metadata_url,
                 self.populate_into_graph.dump(:ttl),
                 { 'Content-Type' => 'application/n-triples' })
      self.reload!
    end

    ##
    # Creates a new item.
    #
    def save_new
      # As of version 4.1, Fedora doesn't like to accept triples via POST for
      # some reason; it just returns 201 Created regardless of the Content-Type
      # header and body content. PUT works, though. So we will POST to create
      # an empty container, and then PUT to that.

      # POST to create a new resource
      headers = { 'Content-Type' => 'application/n-triples' }
      headers['slug'] = self.requested_slug if self.requested_slug
      response = @@http.post(self.container_url, nil, headers)
      self.fedora_url = response.header['Location'].first
      self.requested_slug = nil

      self.reload! # GET its representation in order to append triples to it
      # PUT it back
      @@http.put(self.fedora_metadata_url,
                 self.populate_into_graph.dump(:ttl),
                 { 'Content-Type' => 'text/turtle' })
      # Maybe I'm doing something wrong, but SPARQL via PATCH seems to be the
      # only way to get indexability to work as of Fedora 4.1.
      make_indexable
      self.reload!
    end

  end

end
