module Contentdm

  class Item < Entity

    attr_accessor :collection # Collection
    attr_accessor :created # string date, yyyy-mm-dd
    attr_accessor :filename # string
    attr_accessor :full_text # string
    attr_accessor :parent # Item
    attr_accessor :pointer # integer
    attr_accessor :source_path # string
    attr_accessor :updated # string date, yyyy-mm-dd
    attr_accessor :url # CONTENTdm redirect-to-URL

    ##
    # @param source_path string
    # @param collection Collection
    # @param index Index within a collection
    #
    def self.at_index(source_path, collection, index)
      File.open(File.join(File.expand_path(source_path),
                          collection.alias + '.xml')) do |file|
        doc = Nokogiri::XML(file)
        i = 0
        doc.xpath('//record').each do |record_node|
          return Item.from_cdm_xml(source_path, collection, record_node) if
              i == index
          i += 1
          record_node.xpath('structure/page').each do |page_node|
            return Item.from_cdm_xml(source_path, collection, page_node,
                                     record_node) if i == index
            i += 1
          end
        end
      end
      nil
    end

    ##
    # Builds an item from its CONTENTdm XML representation.
    #
    # @param source_path string
    # @param collection Collection
    # @param node Nokogiri XML node
    # @param parent_node Nokogiri XML node if a compound object page
    # @return Item
    #
    def self.from_cdm_xml(source_path, collection, node, parent_node = nil)
      source_path = File.expand_path(source_path)
      item = Item.new(source_path)
      item.collection = collection

      ptr = node.xpath('cdmid').first
      if ptr # it's an item
        item.pointer = ptr.content
        item.filename = node.xpath('cdmfile').first.content
        item.created = node.xpath('cdmcreated').first.content
        item.updated = node.xpath('cdmmodified').first.content
        item.elements = elements_from_xml(node)
      else # it's a compound object page
        parent_filename = parent_node.xpath('cdmfile').first.content
        cpd_pathname = File.join(source_path, collection.alias, 'image',
                                 parent_filename)
        File.open(cpd_pathname) do |file|
          cpd_doc = Nokogiri::XML(file)
          item.pointer = node.xpath('pageptr').first.content
          item.elements = elements_from_xml(node)
          item.elements << DCElement.new(name: 'title',
                                         value: node.xpath('pagetitle').first.content)
          item.full_text = node.xpath('pagetext').first.content.strip
          item.filename = cpd_doc.
              xpath("//page[pageptr = #{item.pointer}]/pagefile").first.content
          item.source_path = File.join(source_path, collection.alias,
                                       'image', item.filename)
          item.parent = Item.from_cdm_xml(source_path, collection, parent_node)
        end
      end

      item.source_path = source_path

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

    def master_file_pathname
      File.join(File.expand_path(self.source_path), collection.alias, 'image',
                self.filename)
    end

    def pointer=(p)
      @pointer = p.to_i
    end

    private

    def self.elements_from_xml(node)
      elements = []
      node.children.each do |child_node|
        if DCElement::URIS.map{ |e| URI(e).path.split('/').last }.
            include?(child_node.name)
          unless child_node.content.empty?
            content = child_node.content
            if child_node.name.start_with?('subje')
              content.split(';').reject{ |t| t.strip.blank? }.each do |term|
                elements << DCElement.new(name: child_node.name,
                                          value: term.strip)
              end
            else
              elements << DCElement.new(name: child_node.name,
                                        value: content)
            end
          end
        elsif child_node.name == 'unmapped'
          elements << LocalElement.new(value: child_node.content)
        end
      end
      elements
    end

  end

end
