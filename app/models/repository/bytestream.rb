module Repository

  class Bytestream < ActiveMedusa::Binary

    class Shape
      ORIGINAL = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::ORIGINAL_SHAPE
      SQUARE = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::SQUARE_SHAPE
    end

    class Type
      DERIVATIVE = Kumquat::NAMESPACE_URI +
          Kumquat::RDFObjects::DERIVATIVE_BYTESTREAM
      MASTER = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::MASTER_BYTESTREAM
    end

    entity_class_uri Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::BYTESTREAM

    belongs_to :item, class_name: 'Repository::Item',
               predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::PARENT_URI,
               solr_field: Solr::Fields::ITEM

    rdf_property :byte_size,
                 xs_type: :integer,
                 predicate: Kumquat::NAMESPACE_URI + Kumquat::RDFPredicates::BYTE_SIZE,
                 solr_field: Solr::Fields::BYTE_SIZE
    rdf_property :height,
                 xs_type: :integer,
                 predicate: Kumquat::NAMESPACE_URI + Kumquat::RDFPredicates::HEIGHT,
                 solr_field: Solr::Fields::HEIGHT
    rdf_property :media_type,
                 xs_type: :string,
                 predicate: 'http://purl.org/dc/terms/MediaType',
                 solr_field: Solr::Fields::MEDIA_TYPE
    rdf_property :shape,
                 xs_type: :anyURI,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::BYTESTREAM_SHAPE,
                 solr_field: Solr::Fields::BYTESTREAM_SHAPE
    rdf_property :type,
                 xs_type: :anyURI,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::BYTESTREAM_TYPE,
                 solr_field: Solr::Fields::BYTESTREAM_TYPE
    rdf_property :width,
                 xs_type: :integer,
                 predicate: Kumquat::NAMESPACE_URI + Kumquat::RDFPredicates::WIDTH,
                 solr_field: Solr::Fields::WIDTH

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
      self.read_byte_size unless self.byte_size
      self.guess_media_type unless self.media_type
      self.read_dimensions unless self.width and self.height
      super
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

    def public_repository_url
      self.repository_url.gsub(ActiveMedusa::Configuration.fedora_url,
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

    def to_param
      self.uuid
    end
=begin
    def to_sparql_update
      kq_uri = Kumquat::NAMESPACE_URI
      kq_predicates = Kumquat::RDFPredicates
      kq_objects = Kumquat::RDFObjects

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
TODO: fix
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
=end
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

  end

end
