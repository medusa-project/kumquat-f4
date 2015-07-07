module Repository

  class Item < ActiveMedusa::Container

    include BytestreamOwner
    include DerivativeManagement
    include Describable
    include ImageServing
    include Indexable

    WEB_ID_LENGTH = 5

    entity_class_uri Kumquat::NAMESPACE_URI + Kumquat::RDFObjects::ITEM

    belongs_to :collection, class_name: 'Repository::Collection',
               predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::IS_MEMBER_OF_COLLECTION,
               solr_field: Solr::Fields::COLLECTION
    belongs_to :item, class_name: 'Repository::Item',
               predicate: Kumquat::NAMESPACE_URI +
                   Kumquat::RDFPredicates::IS_MEMBER_OF_ITEM,
               solr_field: Solr::Fields::ITEM,
               name: :parent_item
    has_many :bytestreams, class_name: 'Repository::Bytestream'
    has_many :items, class_name: 'Repository::Item'

    rdf_property :full_text,
                 xs_type: :string,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::FULL_TEXT,
                 solr_field: Solr::Fields::FULL_TEXT
    rdf_property :page_index,
                 xs_type: :integer,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::PAGE_INDEX,
                 solr_field: Solr::Fields::PAGE_INDEX
    rdf_property :published,
                 xs_type: :boolean,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::PUBLISHED,
                 solr_field: Solr::Fields::PUBLISHED
    rdf_property :web_id,
                 xs_type: :string,
                 predicate: Kumquat::NAMESPACE_URI +
                     Kumquat::RDFPredicates::WEB_ID,
                 solr_field: Solr::Fields::WEB_ID

    #validates :title, length: { minimum: 2, maximum: 200 }
    validates :web_id, length: { minimum: WEB_ID_LENGTH,
                                 maximum: WEB_ID_LENGTH }

    before_create { self.web_id = generate_web_id }

    def initialize(params = {})
      @published = true
      super
    end

    def ==(other)
      other.kind_of?(Repository::Item) and self.uuid == other.uuid
    end

    ##
    # @return boolean True if any text was extracted; false if not
    #
    def extract_and_update_full_text
      if self.master_bytestream and self.master_bytestream.repository_url
        begin
          yomu = Yomu.new(self.master_bytestream.repository_url)
          self.full_text = yomu.text.force_encoding('UTF-8')
        rescue Errno::EPIPE
          # nothing we can do
          return false
        else
          return self.full_text.present?
        end
      end
      false
    end

    def to_s
      self.title || self.web_id
    end

    def to_param
      self.web_id
    end

    def reindex
      kq_predicates = Kumquat::RDFPredicates

      doc = base_solr_document
      doc[Solr::Fields::COLLECTION] =
          self.rdf_graph.any_object(kq_predicates::IS_MEMBER_OF_COLLECTION)
      doc[Solr::Fields::FULL_TEXT] =
          self.rdf_graph.any_object(kq_predicates::FULL_TEXT)
      doc[Solr::Fields::ITEM] =
          self.rdf_graph.any_object(kq_predicates::IS_MEMBER_OF_ITEM)
      doc[Solr::Fields::PAGE_INDEX] =
          self.rdf_graph.any_object(kq_predicates::PAGE_INDEX)
      doc[Solr::Fields::PUBLISHED] =
          self.rdf_graph.any_object(kq_predicates::PUBLISHED)
      doc[Solr::Fields::SINGLE_TITLE] = self.title
      doc[Solr::Fields::WEB_ID] =
          self.rdf_graph.any_object(kq_predicates::WEB_ID)

=begin TODO: fix this
      date = self.rdf_graph.any_object(kq_predicates::DATE).to_s.strip
      if date.present?
        data[Solr::Fields::DATE] = DateTime.parse(date).iso8601 + 'Z'
      end
=end

      Solr::Solr.client.add(doc)
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

  end

end
