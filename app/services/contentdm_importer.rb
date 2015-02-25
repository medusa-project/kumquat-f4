class ContentdmImporter

  ##
  # @param source_path Path to the source CONTENTdm content folder
  #
  def initialize(source_path)
    @source_path = source_path
    @root_container_url = Kumquat::Application.kumquat_config[:fedora_url]
    @http = HTTPClient.new
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
    container = Container.create(@root_container_url, collection.slug)
    collection.fedora_url = container.fedora_url

    # GET the newly created container's JSON-LD representation
    struct = JSON.parse(container.fedora_json_ld)

    # append metadata to the JSON-LD representation via PUT
    url = "#{collection.fedora_url}/fcr:metadata"
    body = collection.to_json_ld(struct)
    @http.put(url, body, { 'Content-Type' => 'application/ld+json' })

    File.open(File.join(File.expand_path(@source_path),
                        collection.alias + '.xml')) do |file|
      doc = Nokogiri::XML(file)
      doc.xpath('//record').each do |record|
        item = Contentdm::Item.from_cdm_xml(@source_path, collection, record)
        self.import_item(item)
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
  def import_item(item, container_url = nil, make_indexable = true)
    container_url ||= item.collection.fedora_url

    puts "#{item.collection.alias} #{item.pointer}"

    # create a new item container
    container = Container.create(container_url, item.slug)
    item.fedora_url = container.fedora_url

    # GET the newly created container's JSON-LD representation
    struct = JSON.parse(container.fedora_json_ld)

    # append metadata to the JSON-LD representation via PUT
    url = "#{item.fedora_url}/fcr:metadata"
    body = item.to_json_ld(struct)
    @http.put(url, body, { 'Content-Type' => 'application/ld+json' })

    # create a binary resource for the item's bytestream within the item
    # container
    pathname = item.pages.any? ? nil : item.master_file_pathname
    if item.url
      f4_item = Bytestream.create(item.fedora_url, nil, nil, item.url)
      item.bytestream_url = f4_item.fedora_url
    elsif pathname and File.exists?(pathname)
      f4_item = Bytestream.create(item.fedora_url, nil, pathname)
      item.bytestream_url = f4_item.fedora_url
    end

    item.make_indexable if make_indexable

    item.pages.each { |page| self.import_item(page, item.fedora_url, false) }

    item.fedora_url
  end

end