module SampleData

  ##
  # An import delegate for the sample collections.
  #
  class ImportDelegate < ::Import::AbstractDelegate

    LOCAL_NAMESPACE = 'http://example.net/'
    SOURCE_PATH = File.join(Rails.root, 'lib', 'sample_data', 'bytestreams')

    def initialize
      @metadata_pathname = File.join(File.dirname(__FILE__), 'metadata.xml')
      @root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      @collections = [] # array of RDF::Graphs
      @items = [] # array of RDF::Graphs
    end

    def before_import(transaction_url)
      # delete any old collections that may be lying around from
      # previous/failed imports
      collections.each do |collection|
        collection.each_statement do |statement|
          if statement.predicate.to_s == "#{LOCAL_NAMESPACE}key"
            Repository::Collection.delete_with_key(statement.object.to_s) rescue nil
          end
        end
      end
    end

    def total_number_of_items
      items.length
    end

    def collection_key_of_item_at_index(index)
      collection_of_item_at_index(index).each_statement do |statement|
        return statement.object.to_s if
            statement.predicate.to_s == "#{LOCAL_NAMESPACE}key"
      end
      nil
    end

    def full_text_of_item_at_index(index)
      items[index].each_statement do |statement|
        return statement.object.to_s if
            statement.predicate.to_s == 'http://example.org/fullText'
      end
      nil
    end

    def import_id_of_item_at_index(index)
      "#{collection_key_of_item_at_index(index)}-#{index}"
    end

    def parent_import_id_of_item_at_index(index)
      parent = parent_of_item_at_index(index)
      parent ? import_id_of_item_at_index(index_of_item(parent)) : nil
    end

    def master_pathname_of_item_at_index(index)
      items[index].each_statement do |statement|
        return File.join(SOURCE_PATH, statement.object.to_s) if
            statement.predicate.to_s == "#{LOCAL_NAMESPACE}filename"
      end
      nil
    end

    def media_type_of_item_at_index(index)
      items[index].each_statement do |statement|
        return statement.object.to_s if
            statement.predicate.to_s == 'http://purl.org/dc/terms/MediaType'
      end
      nil
    end

    def metadata_of_collection_of_item_at_index(index)
      graph = RDF::Graph.new
      collection_of_item_at_index(index).each_statement do |statement|
        graph << statement if
            !statement.predicate.to_s.start_with?(LOCAL_NAMESPACE) and
                !statement.object.to_s.blank?
      end
      graph
    end

    def metadata_of_item_at_index(index)
      graph = RDF::Graph.new
      items[index].each_statement do |statement|
        graph << statement if
            !statement.predicate.to_s.start_with?(LOCAL_NAMESPACE) and
                !statement.object.to_s.blank?
      end
      graph
    end

    def slug_of_collection_of_item_at_index(index)
      collection_of_item_at_index(index).each_statement do |statement|
        return statement.object.to_s if
            statement.predicate.to_s == "#{LOCAL_NAMESPACE}key"
      end
      nil
    end

    private

    def collection_of_item_at_index(index)
      collection_subject = nil
      items[index].each_statement do |statement|
        if statement.predicate.to_s == "#{LOCAL_NAMESPACE}partOfCollection"
          collection_subject = statement.object.to_s
          break
        end
      end
      if collection_subject
        collections.each do |collection|
          if collection.has_subject?(RDF::URI(collection_subject))
            return collection
          end
        end
      end
      nil
    end

    def collections
      unless @collections.any?
        subjects = []
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          subjects = reader.subjects.select do |subject|
            subject.to_s.start_with?("#{LOCAL_NAMESPACE}collections/")
          end
        end
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          reader.each_statement do |statement|
            if statement.subject.to_s.start_with?("#{LOCAL_NAMESPACE}collections/")
              index = subjects.find_index(statement.subject)
              @collections[index] = RDF::Graph.new unless
                  @collections[index].kind_of?(RDF::Graph)
              @collections[index] << statement
            end
          end
        end
      end
      @collections
    end

    def index_of_item(in_graph)
      return nil unless in_graph
      index = 0
      items.each_with_index do |item_graph, i|
        index = i
        break if item_graph.subjects.first == in_graph.subjects.first
      end
      index
    end

    def items
      unless @items.any?
        subjects = []
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          subjects = reader.subjects.select do |subject|
            subject.to_s.start_with?("#{LOCAL_NAMESPACE}items/")
          end
        end
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          reader.each_statement do |statement|
            if statement.subject.to_s.start_with?("#{LOCAL_NAMESPACE}items/")
              index = subjects.find_index(statement.subject)
              @items[index] = RDF::Graph.new unless
                  @items[index].kind_of?(RDF::Graph)
              @items[index] << statement
            end
          end
        end
      end
      @items
    end

    def parent_of_item_at_index(index)
      items[index].each_statement do |statement|
        if statement.predicate.to_s == "#{LOCAL_NAMESPACE}hasParent"
          items.each do |graph|
            return graph if graph.has_subject?(statement.object)
          end
        end
      end
      nil
    end

  end

end
