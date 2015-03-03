module Contentdm

  class Item < Entity

    DC_ELEMENTS_TO_IMPORT = %w(abstract accessRights accrualMethod
    accrualPeriodicity accrualPolicy alternative audience available
    bibliographicCitation conformsTo contributor coverage created creator date
    dateAccepted dateCopyrighted dateSubmitted description educationLevel
    extent format hasFormat hasPart hasVersion identifier instructionalMethod
    isFormatOf isPartOf isReferencedBy isReplacedBy isRequiredBy issued
    isVersionOf language license mediator medium modified provenance publisher
    relation references relation replaces requires rights rightsHolder source
    spatial subject tableOfContents temporal title type valid)
    WEB_ID_LENGTH = 5

    attr_accessor :collection # Collection
    attr_accessor :created # string date, yyyy-mm-dd
    attr_accessor :filename # string
    attr_accessor :full_text # string
    attr_accessor :pages # array of Items
    attr_accessor :pointer # integer
    attr_accessor :source_path # string
    attr_accessor :updated # string date, yyyy-mm-dd
    attr_accessor :url # CONTENTdm redirect-to-URL

    ##
    # Builds an item from its CONTENTdm XML representation.
    #
    # @param source_path string
    # @param collection Collection
    # @param fragment Nokogiri XML node
    # @return Item
    #
    def self.from_cdm_xml(source_path, collection, node)
      source_path = File.expand_path(source_path)
      item = Item.new
      item.collection = collection
      item.pointer = node.xpath('cdmid').first.content
      item.filename = node.xpath('cdmfile').first.content
      item.created = node.xpath('cdmcreated').first.content
      item.updated = node.xpath('cdmmodified').first.content
      item.source_path = source_path

      # populate metadata
      item.elements = elements_from_xml(node)

      # populate pages
      page_nodes = node.xpath('structure/page')
      if page_nodes.any?
        cpd_pathname = File.join(source_path, collection.alias, 'image',
                                 item.filename)
        File.open(cpd_pathname) do |file|
          cpd_doc = Nokogiri::XML(file)
          page_nodes.each do |page_elem|
            page = Item.new
            page.collection = collection
            page.pointer = page_elem.xpath('pageptr').first.content
            page.elements = elements_from_xml(node)
            page.full_text = page_elem.xpath('pagetext').first.content.strip
            page.filename = cpd_doc.
              xpath("//page[pageptr = #{page.pointer}]/pagefile").first.content
            page.source_path = File.join(source_path, collection.alias,
                                         'image', page.filename)
            item.pages << page
          end
        end
      end

      # populate URL
      if File.extname(item.filename) == '.url'
        File.open(item.master_file_pathname) do |file|
          file.each_line do |line|
            if line.include?('http://')
              item.url = line.gsub('URL=', '').strip
              break
            end
          end
        end
      end

      item
    end

    def initialize
      super
      self.pages = []
    end

    def master_file_pathname
      File.join(File.expand_path(self.source_path), collection.alias, 'image',
                self.filename)
    end

    def slug
      self.pointer.to_s
    end

    ##
    # @param f4_url
    # @param f4_json_structure JSON-LD structure in which to embed the
    # item's metadata
    # @return JSON string
    #
    def to_json_ld(f4_url, f4_json_structure = nil)
      f4_json_structure = [] unless f4_json_structure
      f4_metadata = f4_json_structure.
          select{ |h| h['@id'] == "#{f4_url}/fcr:metadata" }.first
      unless f4_metadata
        f4_metadata = { '@id' => "#{f4_url}/fcr:metadata" }
        f4_json_structure << f4_metadata
      end

      f4_metadata['@context'] = {} unless f4_metadata.keys.include?('@context')

      self.elements.each do |element|
        element_name = element.name ? element.name : 'unmapped'
        f4_metadata['@context'][element.namespace_prefix] = element.namespace_uri
        f4_metadata["#{element.namespace_prefix}:#{element_name}"] = element.value
      end

      f4_metadata['@context']['kumquat'] = Entity::NAMESPACE_URI
      f4_metadata['kumquat:resourceType'] = Fedora::ResourceType::ITEM
      f4_metadata['kumquat:webID'] = generate_web_id
      f4_metadata['kumquat:collectionKey'] = self.collection.alias

      JSON.pretty_generate(f4_json_structure)
    end

    private

    def self.elements_from_xml(node)
      elements = []
      node.children.each do |child_node|
        if DC_ELEMENTS_TO_IMPORT.include?(child_node.name)
          unless child_node.content.empty?
            elements << DCElement.new(name: child_node.name,
                                      value: child_node.content)
          end
        elsif child_node.name == 'unmapped'
          elements << LocalElement.new(value: child_node.content)
        end
      end
      elements
    end

    ##
    # Generates a guaranteed-unique web ID, of which there are
    # 36^WEB_ID_LENGTH available.
    #
    def generate_web_id
      proposed_id = nil
      while true
        proposed_id = (36 ** (WEB_ID_LENGTH - 1) +
            rand(36 ** WEB_ID_LENGTH - 36 ** (WEB_ID_LENGTH - 1))).to_s(36)
        break unless ::Item.find_by_web_id(proposed_id)
      end
      proposed_id
    end

  end

end
