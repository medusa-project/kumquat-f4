module Contentdm

  class Importer

    ##
    # @param source_path Path to the source CONTENTdm content folder
    #
    def initialize(source_path)
      @source_path = source_path
      @root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
      @http = HTTPClient.new
      @solr = Solr::Solr.new
    end

    def import
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

            self.import_cdm_collection(
                Contentdm::Collection.with_alias(col_alias, @source_path))
          end
        end
      end
    end

    ##
    # Ingests a collection and all of its items.
    #
    # @param cdm_collection Contentdm::Collection
    #
    def import_cdm_collection(cdm_collection)
      puts "Ingesting #{cdm_collection.name} (#{cdm_collection.alias})"

      # delete its old container
      url = "#{@root_container_url}/#{cdm_collection.alias}"
      @http.delete(url) rescue nil
      @http.delete("#{url}/fcr:tombstone") rescue nil

      # copy the cdm collection's properties into a new kq collection
      kq_collection = ::Collection.new(container_url: @root_container_url,
                                       requested_slug: cdm_collection.alias)
      cdm_collection.elements.each do |element|
        element_name = element.name ? element.name : 'unmapped'
        kq_collection.triples << ::Triple.new(
            predicate: "#{element.namespace_uri}#{element_name}",
            object: element.value)
      end
      kq_collection.web_id = cdm_collection.alias
      kq_collection.key = cdm_collection.alias
      kq_collection.save!

      File.open(File.join(File.expand_path(@source_path),
                          cdm_collection.alias + '.xml')) do |file|
        doc = Nokogiri::XML(file)
        doc.xpath('//record').each do |record|
          cdm_item = Contentdm::Item.from_cdm_xml(@source_path, cdm_collection,
                                                  record)
          self.import_cdm_item(cdm_item, kq_collection,
                               kq_collection.repository_url)
        end
      end
    end

    ##
    # Ingests an item and all of its pages (if a compound object).
    #
    # @param cdm_item Contentdm::Item
    # @param parent_container_url string
    # @param parent_item_uuid string
    # @param page_index integer
    #
    def import_cdm_item(cdm_item, kq_collection, parent_container_url,
                        parent_item_uuid = nil, page_index = nil)
      puts "#{cdm_item.collection.alias} #{cdm_item.pointer}"

      # create a new Kumquat item (analog of the CONTENTdm cdm_item)
      kq_item = ::Item.new(container_url: parent_container_url,
                           requested_slug: cdm_item.pointer,
                           parent_uuid: parent_item_uuid,
                           collection: kq_collection)
      cdm_item.elements.each do |element|
        element_name = element.name ? element.name : 'unmapped'
        kq_item.triples << ::Triple.new(
            predicate: "#{element.namespace_uri}#{element_name}",
            object: element.value)
      end
      kq_item.page_index = page_index
      kq_item.save!

      # append bytestream to the Kumquat item
      pathname = cdm_item.pages.any? ? nil : cdm_item.master_file_pathname
      if cdm_item.url
        bs = ::Bytestream.new(owner: kq_item,
                              external_resource_url: cdm_item.url,
                              type: Bytestream::Type::MASTER)
        bs.save
        kq_item.bytestreams << bs
      elsif pathname and File.exists?(pathname)
        bs = ::Bytestream.new(owner: kq_item,
                              upload_pathname: pathname,
                              type: Bytestream::Type::MASTER)
        bs.save
        kq_item.bytestreams << bs
      end

      cdm_item.pages.each_with_index do |p, i|
        self.import_cdm_item(p, kq_collection, kq_item.repository_url,
                             kq_item.uuid, i)
      end

      @solr.commit
    end

  end

end
