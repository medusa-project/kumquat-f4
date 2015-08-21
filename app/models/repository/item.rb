module Repository

  class Item < ActiveMedusa::Container

    include ActiveMedusa::Indexable
    include BytestreamOwner
    include Describable
    include ImageServing

    WEB_ID_LENGTH = 5

    entity_class_uri 'http://pcdm.org/models#Object'

    belongs_to :collection, class_name: 'Repository::Collection',
               rdf_predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::IS_MEMBER_OF_COLLECTION,
               solr_field: Solr::Fields::COLLECTION
    belongs_to :item, class_name: 'Repository::Item',
               rdf_predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::IS_MEMBER_OF_ITEM,
               solr_field: Solr::Fields::ITEM,
               name: :parent_item
    has_many :bytestreams, class_name: 'Repository::Bytestream'
    has_many :items, class_name: 'Repository::Item'

    property :full_text,
             type: :string,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::FULL_TEXT,
             solr_field: Solr::Fields::FULL_TEXT
    # The media type of the master bytestream. This duplicates the same
    # property on the master bytestream, but it's needed in order to make Solr
    # queries less awkward.
    property :media_type,
             type: :string,
             rdf_predicate: 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType',
             solr_field: Solr::Fields::MEDIA_TYPE
    property :page_index,
             type: :integer,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::PAGE_INDEX,
             solr_field: Solr::Fields::PAGE_INDEX
    property :published,
             type: :boolean,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::PUBLISHED,
             solr_field: Solr::Fields::PUBLISHED
    property :web_id,
             type: :string,
             rdf_predicate: Kumquat::NAMESPACE_URI +
                 Kumquat::RDFPredicates::WEB_ID,
             solr_field: Solr::Fields::WEB_ID

    #validates :title, length: { minimum: 2, maximum: 200 }
    validates :web_id, length: { minimum: WEB_ID_LENGTH,
                                 maximum: WEB_ID_LENGTH }

    before_create { self.web_id = generate_web_id }

    def initialize(params = {})
      self.published = true
      super
    end

    def ==(other)
      other.kind_of?(self.class) and self.uuid == other.uuid
    end

    ##
    # @return [Boolean] True if any text was extracted; false if not
    #
    def extract_and_update_full_text
      if self.master_bytestream and self.master_bytestream.repository_url
        begin
          yomu = Yomu.new(self.master_bytestream.repository_url)
          self.full_text = yomu.text.force_encoding('UTF-8')
        rescue Errno::EPIPE
          return false # nothing we can do
        else
          return self.full_text.present?
        end
      end
      false
    end

    ##
    # Overrides ActiveMedusa::Indexable.solr_document
    #
    def solr_document
      kq_predicates = Kumquat::RDFPredicates
      doc = super
      doc[Solr::Fields::SINGLE_TITLE] = self.title
      date = self.rdf_graph.any_object(kq_predicates::DATE).to_s.strip
      doc[Solr::Fields::DATE] = normalized_date(date)
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
      self.web_id
    end

    def to_s
      self.title || self.web_id
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
        break unless self.class.find_by_web_id(proposed_id)
      end
      proposed_id
    end

    ##
    # Tries to extract a date from an input string.
    #
    # @param date_str [String]
    # @return [DateTime, nil]
    #
    def normalized_date(date_str)
      if date_str.present?
        # if the string contains a 4 digit number, assume it's a year
        year = date_str.match(/[0-9]{4,}/)
        if year
          dt = DateTime.strptime(year.to_s, '%Y')
          return dt.iso8601 + 'Z'
          # TODO: extract months/days
        end
      end
      nil
    end

  end

end
