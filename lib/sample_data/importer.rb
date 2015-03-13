module SampleData

  ##
  # Imports bytestreams and metadata from db/seed_data into a collection titled
  # "Sample Collection".
  #
  class Importer

    COLLECTION_KEY = 'kq_sample'

    def initialize
      @source_path = File.join(Rails.root, 'lib', 'sample_data',
                               'sample_collection')
      @root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      @http = HTTPClient.new
      @solr = Solr::Solr.new
    end

    def import
      puts 'Ingesting Sample Collection'

      # delete its old container
      url = "#{@root_container_url}/#{COLLECTION_KEY}"
      @http.delete(url) rescue nil
      @http.delete("#{url}/fcr:tombstone") rescue nil

      metadata_pathname = File.join(@source_path, 'metadata.xml')
      RDF::RDFXML::Reader.open(metadata_pathname) do |reader|
        # import the collection itself
        kq_collection = nil
        reader.each_subject do |subject|
          if subject.to_s == 'http://example.net/collections/sample'
            kq_collection = ::Collection.new(container_url: @root_container_url,
                                             requested_slug: COLLECTION_KEY,
                                             web_id: COLLECTION_KEY,
                                             key: COLLECTION_KEY)
            reader.each_statement do |statement|
              if statement.subject == subject
                kq_collection.triples << Triple.new(
                    predicate: statement.predicate.to_s,
                    object: statement.object.to_s)
              end
            end
            kq_collection.save!
            break
          end
        end

        # import the collection's items
        subjects = []
        reader.each_subject { |s| subjects << s.to_s }
        subjects.each do |subject|
          next if subject == 'http://example.net/collections/sample'
          kq_item = ::Item.new(container_url: kq_collection.repository_url,
                               collection: kq_collection)
          reader.each_statement do |statement|
            if statement.subject.to_s == subject
              if statement.predicate.to_s == Kumquat::Application::NAMESPACE_URI +
                  Fedora::Repository::LocalTriples::FULL_TEXT
                kq_item.full_text = statement.object.to_s
              else
                kq_item.triples << Triple.new(predicate: statement.predicate.to_s,
                                              object: statement.object.to_s)
              end
            end
          end
          puts "#{kq_item.triple('http://purl.org/dc/elements/1.1/title').object}"
          kq_item.save!

          # append a bytestream to the Kumquat item
          filename = kq_item.triple('http://example.net/filename').object
          pathname = File.join(@source_path, filename)
          bs = ::Bytestream.new(owner: kq_item,
                                upload_pathname: pathname,
                                type: Bytestream::Type::MASTER)
          bs.save
          kq_item.bytestreams << bs
        end
      end
      @solr.commit
    end

  end

end
