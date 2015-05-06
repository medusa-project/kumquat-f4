module Repository

  ##
  # Encapsulates a Fedora binary resource. Bytestreams implement a similar API
  # as ActiveKumquat::Base, but do not descend from that class as they are not
  # indexable, so they cannot be retrieved with finder methods.
  #
  # TODO: extend ActiveKumquat::Base
  #
  class Bytestream

    include ActiveModel::Model
    include ActiveKumquat::Transactions

    ENTITY_CLASS = ActiveKumquat::Base::Class::BYTESTREAM

    attr_accessor :byte_size # integer
    attr_accessor :external_resource_url # string
    attr_accessor :height # integer
    attr_accessor :media_type # string
    attr_accessor :owner # ActiveKumquat::Base subclass
    attr_accessor :repository_url # string
    attr_accessor :transaction_url # string
    attr_accessor :shape # Bytestream::Shape
    attr_accessor :type # Bytestream::Type
    attr_accessor :upload_pathname # string
    attr_accessor :uuid # string
    attr_accessor :width # integer

    validates_presence_of :owner

    class Shape
      ORIGINAL = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::ORIGINAL_SHAPE
      SQUARE = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::SQUARE_SHAPE
    end

    class Type
      DERIVATIVE = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::DERIVATIVE_BYTESTREAM
      MASTER = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::MASTER_BYTESTREAM
    end

    @@http = HTTPClient.new

    ##
    # Returns a list of image media types for which we can presume to be able
    # to generate derivatives. This will be a subset of
    # types_with_image_derivatives.
    #
    def self.derivable_image_types
      %w(gif jp2 jpg png tif).map do |ext| # TODO: there are more than this
        MIME::Types.of(ext).map{ |type| type.to_s }
      end
    end

    ##
    # Returns a list of media types for which we can expect that image
    # derivatives will be available. This will be a superset of
    # derivable_image_types.
    #
    def self.types_with_image_derivatives
      # TODO: there are more than this
      self.derivable_image_types + %w(video/mpeg video/quicktime video/mp4)
    end

    def initialize(params = {})
      params.except(:id, :uuid).each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
      @destroyed = false
      @persisted = false
      self.read_byte_size unless self.byte_size
      self.guess_media_type unless self.media_type
      self.read_dimensions unless self.width and self.height
    end

    ##
    # @param also_tombstone boolean
    # @param commit_immediately boolean
    #
    def delete(also_tombstone = false, commit_immediately = true)
      if self.repository_url
        url = transactional_url(self.repository_url).chomp('/')
        @@http.delete(url)
        @@http.delete("#{url}/fcr:tombstone") if also_tombstone
        @destroyed = true
        @persisted = false
        self.owner.bytestreams.delete(self)

        if commit_immediately
          # wait for solr to get the delete from fcrepo-message-consumer
          # TODO: this is horrible
          sleep 2
          Solr::Solr.client.commit
        end
      end
    end

    alias_method :destroy, :delete
    alias_method :destroy!, :delete

    def destroyed?
      @destroyed
    end

    def guess_media_type
      type = nil
      if self.upload_pathname and File.exist?(self.upload_pathname)
        type = MIME::Types.of(self.upload_pathname).first.to_s
      elsif self.external_resource_url
        type = MIME::Types.of(self.external_resource_url).first.to_s
      end
      self.media_type = type if type
    end

    def is_audio?
      self.media_type and self.media_type.start_with?('audio/')
    end

    def is_image?
      self.media_type and self.media_type.start_with?('image/')
    end

    def is_pdf?
      self.media_type and self.media_type == 'application/pdf'
    end

    def is_text?
      self.media_type and self.media_type.start_with?('text/')
    end

    def is_video?
      self.media_type and self.media_type.start_with?('video/')
    end

    def persisted?
      @persisted and !@destroyed
    end

    ##
    # Populates the instance with data from an RDF graph.
    #
    # @param graph RDF::Graph
    #
    def populate_from_graph(graph)
      kq_predicates = Kumquat::Application::RDFPredicates
      graph.each_triple do |subject, predicate, object|
        if predicate == 'http://purl.org/dc/terms/MediaType'
          self.media_type = object.to_s
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}#{kq_predicates::BYTE_SIZE}"
          self.byte_size = object.to_s.to_i
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}#{kq_predicates::HEIGHT}"
          self.height = object.to_s.to_i
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}#{kq_predicates::BYTESTREAM_TYPE}"
          self.type = object.to_s
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}#{kq_predicates::BYTESTREAM_SHAPE}"
          self.shape = object.to_s
        elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}#{kq_predicates::WIDTH}"
          self.width = object.to_s.to_i
        elsif predicate == 'http://fedora.info/definitions/v4/repository#uuid'
          self.uuid = object.to_s
        end
      end
      @persisted = true
    end

    def public_repository_url
      self.repository_url.gsub(Kumquat::Application.kumquat_config[:fedora_url],
                               Kumquat::Application.kumquat_config[:public_fedora_url])
    end

    ##
    # Reads the byte size and assigns it to the instance.
    #
    def read_byte_size
      self.byte_size = File.size(self.upload_pathname) if self.upload_pathname
    end

    ##
    # Reads the width and height (if an image) and assigns them to the instance.
    # Only works for images.
    #
    def read_dimensions
      if self.is_image?
        if self.upload_pathname
          read_dimensions_from_pathname(self.upload_pathname)
        elsif self.external_resource_url
          response = @@http.get(self.external_resource_url)
          tempfile = Tempfile.new('tmp')
          tempfile.write(response.body)
          tempfile.close
          read_dimensions_from_pathname(tempfile.path)
          tempfile.unlink
        end
      end
    end

    def reload!
      url = self.repository_metadata_url # already transactionalized
      response = @@http.get(url, nil, { 'Accept' => 'application/n-triples' })
      graph = RDF::Graph.new
      graph.from_ntriples(response.body)
      self.populate_from_graph(graph)
    end

    def repository_metadata_url
      url = transactional_url(self.repository_url).chomp('/')
      "#{url}/fcr:metadata"
    end

    def save(commit_immediately = true) # TODO: look into Solr soft commits
      raise "Validation error: #{self.errors.messages.first}" unless self.valid?
      if self.destroyed?
        raise RuntimeError, 'Cannot save a destroyed object.'
      elsif self.uuid
        save_existing
      else
        save_new
      end
      @persisted = true
      self.owner.bytestreams << self
      if commit_immediately
        # wait for solr to get the add from fcrepo-message-consumer
        # TODO: this is horrible (also doing it in delete())
        sleep 2
        Solr::Solr.client.commit
      end
    end

    alias_method :save!, :save

    def to_param
      self.uuid
    end

    def to_sparql_update
      kq_uri = Kumquat::Application::NAMESPACE_URI
      kq_predicates = Kumquat::Application::RDFPredicates
      kq_objects = Kumquat::Application::RDFObjects

      update = ActiveKumquat::SparqlUpdate.new
      update.prefix('kumquat', kq_uri).prefix('dcterms', 'http://purl.org/dc/terms/')
      owner_uri = "<#{self.owner.repository_url}>"
      my_uri = "<#{self.repository_url}>"
      my_metadata_uri = "<#{self.repository_metadata_url}>"
      update.delete(my_metadata_uri, '<dcterms:MediaType>', '?o').
          insert(my_metadata_uri, 'dcterms:MediaType', self.media_type)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::BYTE_SIZE}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::BYTE_SIZE}", self.byte_size)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::BYTESTREAM_TYPE}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::BYTESTREAM_TYPE}",
                 "<#{self.type}>", false)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::WIDTH}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::WIDTH}", self.width.to_i)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::HEIGHT}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::HEIGHT}", self.height.to_i)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::BYTESTREAM_SHAPE}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::BYTESTREAM_SHAPE}",
                 "<#{self.shape}>", false)
      update.delete(my_metadata_uri, "<kumquat:#{kq_predicates::CLASS}>", '?o').
          insert(my_metadata_uri, "kumquat:#{kq_predicates::CLASS}",
                 "<#{kq_uri}#{kq_objects::BYTESTREAM}>", false)

      # also update the owning entity with some useful properties that we can't
      # easily query for without a triple store
      update.delete(owner_uri, "<kumquat:#{kq_predicates::BYTESTREAM_URI}>", "<#{my_uri}>").
          insert(owner_uri, "kumquat:#{kq_predicates::BYTESTREAM_URI}", my_uri, false)
      if self.type == Type::MASTER
        update.delete(owner_uri, "<kumquat:#{kq_predicates::BYTE_SIZE}>", '?o').
            insert(owner_uri, "kumquat:#{kq_predicates::BYTE_SIZE}", self.byte_size)
        update.delete(owner_uri, "<kumquat:#{kq_predicates::HEIGHT}>", '?o').
            insert(owner_uri, "kumquat:#{kq_predicates::HEIGHT}", self.height.to_i)
        update.delete(owner_uri, '<dcterms:MediaType>', '?o').
            insert(owner_uri, 'dcterms:MediaType', self.media_type)
        update.delete(owner_uri, "<kumquat:#{kq_predicates::WIDTH}>", '?o').
            insert(owner_uri, "kumquat:#{kq_predicates::WIDTH}", self.width.to_i)
      end
      update
    end

    private

    ##
    # @param pathname string
    # @return void
    #
    def read_dimensions_from_pathname(pathname)
      glue = '|'
      output = `identify -format "%[fx:w]#{glue}%[fx:h]" #{pathname}`
      parts = output.split(glue)
      if parts.length == 2
        self.width = parts[0].strip.to_i
        self.height = parts[1].strip.to_i
      end
    end

    ##
    # Updates an existing bytestream.
    #
    def save_existing
      url = self.repository_metadata_url # already transactionalized
      update = self.to_sparql_update
      @@http.patch(url, update.to_s,
                   { 'Content-Type' => 'application/sparql-update' })
    end

    ##
    # Creates a new bytestream.
    #
    def save_new
      raise 'Validation error' unless self.valid?
      raise 'Owner must have a Fedora container URL before a bytestream can be '\
        'added.' unless self.owner.repository_url
      response = nil
      if self.upload_pathname
        File.open(self.upload_pathname) do |file|
          filename = File.basename(self.upload_pathname)
          headers = {
              'Content-Disposition' => "attachment; filename=\"#{filename}\""
          }
          headers['Content-Type'] = self.media_type unless self.media_type.blank?
          url = transactional_url(self.owner.repository_url)
          response = @@http.post(url, file, headers)
        end
      elsif self.external_resource_url
        url = transactional_url(self.owner.repository_url)
        response = @@http.post(url, nil,
                               { 'Content-Type' => 'text/plain' })
        headers = { 'Content-Type' => "message/external-body; "\
          "access-type=URL; URL=\"#{self.external_resource_url}\"" }
        @@http.put(response.header['Location'].first, nil, headers)
      end
      self.repository_url = nontransactional_url(
          response.header['Location'].first)
      save_existing
    end

  end

end
