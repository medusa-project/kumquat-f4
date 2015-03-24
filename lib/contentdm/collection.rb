module Contentdm

  class Collection < Entity

    # map of colldesc.txt tag names (first 3 characters) to DC element names
    TAG_DC_MAP = {
        'aud' => 'audience',
        'con' => 'contributor',
        'cov' => 'coverage',
        'cre' => 'creator',
        'dat' => 'date',
        'des' => 'description',
        'for' => 'format',
        'ide' => 'identifier',
        'lan' => 'language',
        'pub' => 'publisher',
        'rel' => 'relation',
        'rig' => 'rights',
        'sou' => 'source',
        'sub' => 'subject',
        'tit' => 'title',
        'typ' => 'type'
    }

    attr_accessor :alias

    ##
    # @param alias_ CONTENTdm collection alias
    # @param source_path
    # @return Collection
    #
    def self.with_alias(alias_, source_path)
      collection = Collection.new(source_path)
      collection.alias = alias_.gsub('/', '')

      desc_pathname = File.join(File.expand_path(source_path),
                                collection.alias, 'index', 'etc', 'colldesc.txt')
      about_pathname = File.join(File.expand_path(source_path),
                                 collection.alias, 'index', 'etc', 'about.txt')
      catalog_pathname = File.join(File.expand_path(source_path), 'catalog.txt')
      # If it exists, extract the collection's Dublin Core properties from the
      # colldesc.txt file, which despite its name is actually a pseudo-XML file
      # with no root element.
      if File.exists?(desc_pathname)
        File.open(desc_pathname) do |file|
          string = "<?xml version=\"1.0\"?><xml>#{file.readlines}</xml>"
          doc = Nokogiri::XML(string)
          doc.xpath('/xml/*').each do |node|
            element = DCElement.new(
                name: TAG_DC_MAP[node.name[0..2]], value: node.text.gsub('\"', '"'))
            collection.elements << element unless element.value.empty?
          end
        end
      # colldesc.txt might not exist, so check for about.txt instead.
      elsif File.exists?(about_pathname)
        File.open(about_pathname) do |file|
          element = DCElement.new(name: 'description',
                                  value: file.read.squish.strip)
          collection.elements << element unless element.value.empty?
        end
      end
      unless collection.elements.select{ |e| e.name == 'title' }.any?
        # Not all collections have either a colldesc.txt or an about.txt file,
        # so the collection may not yet have a title at this point. So, get it
        # from the catalog.txt file.
        if File.exists?(catalog_pathname)
          File.open(catalog_pathname) do |file|
            file.each_line do |line|
              parts = line.gsub(/\t+/, "\t").split("\t")
              if parts.first == "/#{collection.alias}"
                element = DCElement.new(name: 'title', value: parts[1].strip)
                collection.elements << element unless element.value.empty?
                break
              end
            end
          end
        end
      end
      collection
    end

    def initialize(source_path)
      super
      @num_items = 0
    end

    ##
    # @return The value of the collection's DC title element
    #
    def name
      element = self.elements.select{ |e| e.name == 'title' }.first
      element ? element.value : nil
    end

    ##
    # @return integer
    #
    def num_items
      if @num_items < 1
        File.open(File.join(File.expand_path(@source_path),
                            self.alias + '.xml')) do |file|
          doc = Nokogiri::XML(file)
          records = doc.xpath('//record')
          @num_items = records.length
          @num_items += records.xpath('/structure/page').length
        end
      end
      @num_items
    end

  end

end
