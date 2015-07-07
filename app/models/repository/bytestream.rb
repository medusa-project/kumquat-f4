module Repository

  class Bytestream < ActiveMedusa::Binary

    include Derivable
    include Indexable

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
                   Kumquat::RDFPredicates::IS_MEMBER_OF_ITEM,
               solr_field: Solr::Fields::ITEM

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

    before_save :assign_technical_info, :update_owning_item

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
      self.repository_url.gsub(ActiveMedusa::Configuration.instance.fedora_url,
                               Kumquat::Application.kumquat_config[:public_fedora_url])
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
          response = ActiveMedusa::Fedora.client.get(self.external_resource_url)
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

    def reindex
      kq_predicates = Kumquat::RDFPredicates

      doc = base_solr_document
      doc[Solr::Fields::ITEM] =
          self.rdf_graph.any_object(kq_predicates::IS_MEMBER_OF_ITEM)
      doc[Solr::Fields::BYTE_SIZE] = self.byte_size
      doc[Solr::Fields::HEIGHT] = self.height
      doc[Solr::Fields::MEDIA_TYPE] = self.media_type
      doc[Solr::Fields::BYTESTREAM_SHAPE] = self.shape
      doc[Solr::Fields::BYTESTREAM_TYPE] = self.type
      doc[Solr::Fields::WIDTH] = self.width
      Solr::Solr.client.add(doc)
    end

    private

    def assign_technical_info
      self.guess_media_type unless self.media_type
      self.read_dimensions unless self.width and self.height
    end

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
    # Updates the owning item with some useful properties that can't easily be
    # queried for without a triple store.
    # TODO: look into solr joins instead
    #
    def update_owning_item
      if self.parent
        kq_predicates = Kumquat::RDFPredicates
        self.parent.rdf_graph.delete_predicate(kq_predicates::BYTESTREAM_URI)
        self.parent.rdf_graph << [RDF::URI(), kq_predicates::BYTESTREAM_URI,
                                  RDF::URI(self.repository_url)]
        if self.type == Type::MASTER
          # byte size
          self.parent.rdf_graph << [RDF::URI(),
                                    RDF::URI('http://www.loc.gov/premis/rdf/v1#hasSize'),
                                    self.byte_size] if self.byte_size
          # height
          self.parent.rdf_graph.delete_predicate(kq_predicates::HEIGHT)
          self.parent.rdf_graph << [RDF::URI(), RDF::URI(kq_predicates::HEIGHT),
                                    self.height.to_i] if self.height
          # media type
          self.parent.rdf_graph.delete_predicate('http://purl.org/dc/terms/MediaType')
          self.parent.rdf_graph << [RDF::URI(),
                                    RDF::URI('http://purl.org/dc/terms/MediaType'),
                                    self.media_type] if self.media_type
          # width
          self.parent.rdf_graph.delete_predicate(kq_predicates::WIDTH)
          self.parent.rdf_graph << [RDF::URI(), RDF::URI(kq_predicates::WIDTH),
                                    self.width.to_i] if self.width
        end
        self.parent.save
      end
    end

  end

end
