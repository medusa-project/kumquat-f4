module Contentdm

  class ImportDelegate < ::Import::AbstractDelegate

    def initialize(source_path)
      @collections = []
      @num_items = 0
      @source_path = source_path

      # delete any old collections that may be lying around from
      # previous/failed imports
      collections.each do |cdm_collection|
        Repository::Collection.delete_with_key(cdm_collection.alias) rescue nil
      end
    end

    def total_number_of_items
      @num_items = collections.map{ |c| c.num_items }.sum unless @num_items > 0
      @num_items
    end

    def collection_key_of_item_at_index(index)
      cdm_item_at_index(index).collection.alias
    end

    def full_text_of_item_at_index(index)
      cdm_item_at_index(index).full_text
    end

    def import_id_of_item_at_index(index)
      import_id_for_cdm_item(cdm_item_at_index(index))
    end

    def parent_import_id_of_item_at_index(index)
      item = cdm_item_at_index(index)
      item.parent ? import_id_for_cdm_item(item.parent) : nil
    end

    def master_pathname_of_item_at_index(index)
      pathname = cdm_item_at_index(index).master_file_pathname
      %w(.cpd .url).include?(File.extname(pathname)) ? nil : pathname
    end

    def master_url_of_item_at_index(index)
      cdm_item_at_index(index).url
    end

    def metadata_of_collection_of_item_at_index(index)
      graph = RDF::Graph.new
      cdm_item_at_index(index).collection.elements.each do |element|
        graph << RDF::Statement.new(subject: RDF::URI(),
                                    predicate: RDF::URI(element.uri),
                                    object: element.value)
      end
      graph
    end

    def metadata_of_item_at_index(index)
      graph = RDF::Graph.new
      cdm_item_at_index(index).elements.each do |element|
        graph << RDF::Statement.new(subject: RDF::URI(),
                                    predicate: RDF::URI(element.uri),
                                    object: element.value)
      end
      graph
    end

    def slug_of_collection_of_item_at_index(index)
      collection_key_of_item_at_index(index)
    end

    def slug_of_item_at_index(index)
      cdm_item_at_index(index).pointer.to_s
    end

    def web_id_of_item_at_index(index)
      collection_key_of_item_at_index(index) + '-' +
          cdm_item_at_index(index).pointer.to_s
    end

    private

    def cdm_item_at_index(index)
      begin_offset = end_offset = 0
      collection = nil
      collections.each do |col|
        begin_offset = end_offset
        collection = col
        end_offset += col.num_items
        break if end_offset > index
      end
      #puts "#{begin_offset} #{end_offset} #{index} #{index - begin_offset}"
      #puts collection.alias
      Item.at_index(@source_path, collection, index - begin_offset)
    end

    def collections
      unless @collections.any?
        catalog_pathname = File.join(File.expand_path(@source_path), 'catalog.txt')
        File.open(catalog_pathname) do |file|
          file.each_line do |line|
            parts = line.gsub(/\t+/, "\t").split("\t")
            col_alias = parts.first.strip
            if col_alias[0] != '#'
              collection_folder_pathname = File.join(
                  File.expand_path(@source_path), col_alias)
              next unless File.directory?(collection_folder_pathname)

              metadata_pathname = "#{collection_folder_pathname}.xml"
              raise "#{File.basename(metadata_pathname)} is missing." unless
                  File.exists?(metadata_pathname)

              @collections << Contentdm::Collection.with_alias(col_alias,
                                                               @source_path)
            end
          end
        end
      end
      @collections
    end

    def import_id_for_cdm_item(item)
      "cdm-#{item.collection.alias}-#{item.pointer}"
    end

  end

end
