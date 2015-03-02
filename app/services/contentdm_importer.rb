class ContentdmImporter

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

          self.import_collection(
              Contentdm::Collection.with_alias(col_alias, @source_path))
        end
      end
    end
  end

  ##
  # Ingests a collection and all of its items.
  #
  # @param collection Contentdm::Collection
  #
  def import_collection(collection)
    puts "Ingesting #{collection.name} (#{collection.alias})"

    # delete any old collection containers
    url = "#{@root_container_url}/#{collection.slug}"
    @http.delete(url) rescue nil
    @http.delete("#{url}/fcr:tombstone") rescue nil

    # create a new collection container
    container = Fedora::Container.create(@root_container_url, collection.slug)
    container.fedora_json_ld = collection.to_json_ld(container.fedora_url,
                                                     JSON.parse(container.fedora_json_ld))
    container.save
    container.make_indexable

    File.open(File.join(File.expand_path(@source_path),
                        collection.alias + '.xml')) do |file|
      doc = Nokogiri::XML(file)
      doc.xpath('//record').each do |record|
        item = Contentdm::Item.from_cdm_xml(@source_path, collection, record)
        self.import_item(item, container.fedora_url)
      end
    end
  end

  ##
  # Ingests an item and all of its pages (if a compound object).
  #
  # @param item Contentdm::Item
  # @param container_url string
  # @param make_indexable boolean
  # @return string Resource URL from response Location header
  #
  def import_item(item, container_url, make_indexable = true)
    puts "#{item.collection.alias} #{item.pointer}"

    # create a new item container
    container = Fedora::Container.create(container_url, item.slug)
    container.fedora_json_ld = item.to_json_ld(container.fedora_url,
                                               JSON.parse(container.fedora_json_ld))
    container.save
    container.make_indexable if make_indexable

    # create a binary resource for the item's bytestream within the item
    # container
    pathname = item.pages.any? ? nil : item.master_file_pathname
    if item.url
      Fedora::Bytestream.create(container, nil, nil, item.url)
    elsif pathname and File.exists?(pathname)
      Fedora::Bytestream.create(container, nil, pathname)
    end

    @solr.commit

    item.pages.each { |p| self.import_item(p, container.fedora_url, false) }

    container.fedora_url
  end

end