module Repository

  class Bytestream < ActiveMedusa::Binary

    include ActiveMedusa::Indexable
    include Derivable

    class Shape
      ORIGINAL = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::ORIGINAL_SHAPE
      SQUARE = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::SQUARE_SHAPE
    end

    class Type
      DERIVATIVE = Kumquat::NAMESPACE_URI +
          Kumquat::RDFObjects::DERIVATIVE_BYTESTREAM
      MASTER = Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::MASTER_BYTESTREAM
    end

    entity_class_uri 'http://pcdm.org/models#File'

    belongs_to :item, class_name: 'Repository::Item',
               rdf_predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::IS_MEMBER_OF_ITEM,
               solr_field: Solr::Fields::ITEM

    property :height,
             type: :integer,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::HEIGHT,
             solr_field: Solr::Fields::HEIGHT
    property :media_type,
             type: :string,
             rdf_predicate: 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType',
             solr_field: Solr::Fields::MEDIA_TYPE
    property :shape,
             type: :anyURI,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::BYTESTREAM_SHAPE,
             solr_field: Solr::Fields::BYTESTREAM_SHAPE
    property :type,
             type: :anyURI,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::BYTESTREAM_TYPE,
             solr_field: Solr::Fields::BYTESTREAM_TYPE
    property :width,
             type: :integer,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::WIDTH,
             solr_field: Solr::Fields::WIDTH

    before_create :assign_technical_info
    before_create :update_owning_item

    ##
    # Returns the PREMIS byte size, populated by the repository. Not available
    # until the instance has been persisted.
    #
    # @return [Integer]
    #
    def byte_size
      self.rdf_graph.any_object('http://www.loc.gov/premis/rdf/v1#hasSize').to_i
    end

    ##
    # Returns the PREMIS filename. Not available until the instance has been
    # persisted.
    #
    # @return [String]
    #
    def filename
      self.rdf_graph.any_object('http://www.loc.gov/premis/rdf/v1#hasOriginalName').to_s
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

    ##
    # Overrides ActiveMedusa::Indexable.solr_document
    #
    def solr_document
      doc = super
      doc[Solr::Fields::BYTE_SIZE] = self.byte_size
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
      self.id
    end

    private

    def assign_technical_info
      self.guess_media_type unless self.media_type
      self.read_dimensions unless self.width and self.height
    end

    ##
    # @param pathname [String]
    # @return [void]
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
    # If a master bytestream with a media type, assign the media type to the
    # owning item and save it.
    #
    def update_owning_item
      if self.type == Type::MASTER and self.item.media_type != self.media_type
        self.item.update(media_type: self.media_type)
      end
    end

  end

end
