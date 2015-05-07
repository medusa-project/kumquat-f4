module Repository

  class Item < ActiveKumquat::Base

    include BytestreamOwner
    include DerivativeManagement
    include ImageServing

    ENTITY_CLASS = ActiveKumquat::Base::Class::ITEM
    WEB_ID_LENGTH = 5

    attr_accessor :collection

    rdf_property :collection_key, type: :string,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::COLLECTION_KEY
    rdf_property :full_text, type: :string,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::FULL_TEXT
    rdf_property :page_index, type: :integer,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::PAGE_INDEX
    rdf_property :parent_uri, type: :uri,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::PARENT_URI
    rdf_property :published, type: :boolean,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::PUBLISHED
    rdf_property :resource_type, type: :uri,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::CLASS
    rdf_property :web_id, type: :string,
                 uri: Kumquat::Application::NAMESPACE_URI +
                     Kumquat::Application::RDFPredicates::WEB_ID

    validates :title, length: { minimum: 2, maximum: 200 }
    validates :web_id, length: { minimum: 4, maximum: 7 }

    before_save :set_rdf_properties

    def initialize(params = {})
      @children = []
      @published = true
      @resource_type = Kumquat::Application::NAMESPACE_URI +
          Kumquat::Application::RDFObjects::ITEM
      super(params)
    end

    def ==(other)
      other.kind_of?(Repository::Item) and self.uuid == other.uuid
    end

    ##
    # @return ActiveKumquat::Entity
    #
    def children
      @children = Repository::Item.all.
          where(Solr::Fields::PARENT_URI => "\"#{self.repository_url}\"").
          order(Solr::Fields::PAGE_INDEX) unless @children.any?
      @children
    end

    ##
    # @return Repository::Collection
    #
    def collection
      @collection = Repository::Collection.find_by_key(@collection_key) unless
          @collection
      @collection
    end

    ##
    # @return boolean True if any text was extracted; false if not
    #
    def extract_and_update_full_text
      if self.master_bytestream and self.master_bytestream.repository_url
        begin
          yomu = Yomu.new(self.master_bytestream.repository_url)
          self.full_text = yomu.text
        rescue Errno::EPIPE
          # nothing we can do
          return false
        else
          return self.full_text.present?
        end
      end
      false
    end

    ##
    # @return Repository::Item
    #
    def parent
      unless @parent
        self.rdf_graph.each_statement do |s|
          if s.predicate.to_s == Kumquat::Application::NAMESPACE_URI +
              Kumquat::Application::RDFPredicates::PARENT_URI
            @parent = Repository::Item.find_by_uri(s.object.to_s)
            break
          end
        end
      end
      @parent
    end

    def to_s
      self.title || self.web_id
    end

    def to_param
      self.web_id
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

    def set_rdf_properties
      @web_id = generate_web_id unless @web_id.present?
      @collection_key = self.collection.key
    end

  end

end
