module Repository

  class Item < ActiveKumquat::Base

    include BytestreamOwner
    include DerivativeManagement
    include ImageServing

    ENTITY_CLASS = ActiveKumquat::Base::Class::ITEM

    attr_accessor :collection
    attr_accessor :full_text
    attr_accessor :page_index
    attr_accessor :parent_uri
    attr_accessor :web_id

    validates :title, length: { minimum: 2, maximum: 200 }
    validates :web_id, length: { minimum: 4, maximum: 7 }

    def initialize(params = {})
      @children = []
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
          where(Solr::Solr::PARENT_URI_KEY => "\"#{self.repository_url}\"").
          order(Solr::Solr::PAGE_INDEX_KEY) unless @children.any?
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
    # @return Repository::Item
    #
    def parent
      unless @parent
        self.rdf_graph.each_statement do |s|
          if s.predicate.to_s == Kumquat::Application::NAMESPACE_URI +
              Kumquat::Application::RDFPredicates::PARENT_URI
            @parent = Repository::Item.find_by_uuid(s.object.to_s)
            break
          end
        end
      end
      @parent
    end

    def to_s
      self.title || self.web_id
    end

    ##
    # Overrides parent
    #
    # @param graph RDF::Graph
    #
    def populate_from_graph(graph)
      super(graph)

      kq_uri = Kumquat::Application::NAMESPACE_URI
      kq_predicates = Kumquat::Application::RDFPredicates

      graph.each_triple do |subject, predicate, object|
        case predicate
          when kq_uri + kq_predicates::COLLECTION_KEY
            @collection_key = object.to_s
          when kq_uri + kq_predicates::FULL_TEXT
           self.full_text = object.to_s
          when kq_uri + kq_predicates::PAGE_INDEX
            self.page_index = object.to_s
          when kq_uri + kq_predicates::PARENT_URI
            self.parent_uri = object.to_s
          when kq_uri + kq_predicates::WEB_ID
            self.web_id = object.to_s
        end
      end
    end

    def to_param
      self.web_id
    end

    ##
    # Overrides parent
    #
    # @return ActiveKumquat::SparqlUpdate
    #
    def to_sparql_update
      kq_uri = Kumquat::Application::NAMESPACE_URI
      kq_predicates = Kumquat::Application::RDFPredicates
      kq_objects = Kumquat::Application::RDFObjects

      update = super
      update.prefix('kumquat', kq_uri)
      # web id
      _web_id = self.web_id.blank? ? generate_web_id : self.web_id
      update.delete('<>', "<kumquat:#{kq_predicates::WEB_ID}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::WEB_ID}", _web_id)
      # collection key
      update.delete('<>', "<kumquat:#{kq_predicates::COLLECTION_KEY}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::COLLECTION_KEY}", self.collection.key)
      # full text
      update.delete('<>', "<kumquat:#{kq_predicates::FULL_TEXT}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::FULL_TEXT}", self.full_text) unless
          self.full_text.blank?
      # page index
      update.delete('<>', "<kumquat:#{kq_predicates::PAGE_INDEX}>", '?o', false)
      update.insert(nil, "kumquat:#{kq_predicates::PAGE_INDEX}", self.page_index) unless
          self.page_index.blank?
      # parent uri
      update.delete('<>', "<kumquat:#{kq_predicates::PARENT_URI}>", '?o', false)
      update.insert(nil, "kumquat:#{kq_predicates::PARENT_URI}",
                    "<#{self.parent_uri}>", false) unless self.parent_uri.blank?
      # resource type
      update.delete('<>', "<kumquat:#{kq_predicates::CLASS}>", '?o', false).
          insert(nil, "kumquat:#{kq_predicates::CLASS}",
                 "<#{kq_uri}#{kq_objects::ITEM}>", false)
    end

    private

    ##
    # Generates a guaranteed-unique web ID, of which there are
    # 36^WEB_ID_LENGTH available.
    #
    def generate_web_id
      length = Kumquat::Application.kumquat_config[:web_id_length]
      proposed_id = nil
      while true
        proposed_id = (36 ** (length - 1) +
            rand(36 ** length - 36 ** (length - 1))).to_s(36)
        break unless ActiveKumquat::Base.find_by_web_id(proposed_id)
      end
      proposed_id
    end

  end

end
