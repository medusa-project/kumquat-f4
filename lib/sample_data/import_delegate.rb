module SampleData

  class ImportDelegate < ::Import::AbstractDelegate

    def initialize
      @collection_key = nil
      @source_path = File.join(Rails.root, 'lib', 'sample_data',
                               'sample_collection')
      @metadata_pathname = File.join(@source_path, 'metadata.xml')
      @num_items = 0
      @root_container_url = Kumquat::Application.kumquat_config[:fedora_url]

      # delete any old collections that may be lying around from
      # previous/failed imports
      Repository::Collection.delete_with_key(collection_key) rescue nil
    end

    def total_number_of_items
      if @num_items < 1
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          @num_items = reader.subjects.
              select{ |s| s.start_with?('http://example.net/items') }.length
        end
      end
      @num_items
    end

    def collection_key_of_item_at_index(index)
      collection_key
    end

    def full_text_of_item_at_index(index)
      RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
        subjects = reader.subjects.
            select{ |s| s.start_with?('http://example.net/items') }
        reader.each_statement do |statement|
          if statement.subject.to_s == subjects[index]
            return statement.object.to_s if
                statement.predicate.to_s == 'http://example.org/fullText'
          end
        end
      end
      nil
    end

    def import_id_of_item_at_index(index)
      "#{collection_key}-#{index}"
    end
    end

    def master_pathname_of_item_at_index(index)
      RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
        subjects = reader.subjects.
            select{ |s| s.start_with?('http://example.net/items') }
        reader.each_statement do |statement|
          if statement.subject.to_s == subjects[index]
            if statement.predicate.to_s == 'http://example.net/filename'
              return File.join(@source_path, statement.object.to_s)
            end
          end
        end
      end
      nil
    end

    def media_type_of_item_at_index(index)
      RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
        subjects = reader.subjects.
            select{ |s| s.start_with?('http://example.net/items') }
        reader.each_statement do |statement|
          if statement.subject.to_s == subjects[index]
            return statement.object.to_s if
                statement.predicate.to_s == 'http://purl.org/dc/elements/1.1/format'
          end
        end
      end
      nil
    end

    def metadata_of_collection_of_item_at_index(index)
      graph = RDF::Graph.new
      RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
        reader.each_statement do |statement|
          if statement.subject.to_s == 'http://example.net/collections/sample'
            graph << statement
          end
        end
      end
      graph
    end

    def metadata_of_item_at_index(index)
      graph = RDF::Graph.new
      RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
        subjects = reader.subjects.
            select{ |s| s.start_with?('http://example.net/items') }
        reader.each_statement do |statement|
          if statement.subject.to_s == subjects[index]
            graph << statement unless
                statement.predicate.to_s.start_with?('http://example.net/')
          end
        end
      end
      graph
    end

    def slug_of_collection_of_item_at_index(index)
      collection_key
    end

    private

    def collection_key
      unless @collection_key
        RDF::RDFXML::Reader.open(@metadata_pathname) do |reader|
          reader.each_statement do |statement|
            if statement.subject.to_s == 'http://example.net/collections/sample'
              if statement.predicate.to_s == 'http://example.net/key'
                @collection_key = statement.object.to_s
              end
            end
          end
        end
      end
      @collection_key
    end

  end

end
