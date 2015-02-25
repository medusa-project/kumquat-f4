module Contentdm

  class Collection

    include Describable

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
    attr_accessor :fedora_url

    ##
    # @param alias_ CONTENTdm collection alias
    # @param source_path
    # @return Collection
    #
    def self.with_alias(alias_, source_path)
      collection = Collection.new
      collection.alias = alias_.gsub('/', '')

      # Extract the collection's Dublin Core properties from the colldesc.txt
      # file, which despite its name is actually a pseudo-XML file with no root
      # element.
      desc_pathname = File.join(File.expand_path(source_path),
                                collection.alias, 'index', 'etc', 'colldesc.txt')
      catalog_pathname = File.join(File.expand_path(source_path), 'catalog.txt')
      if File.exists?(desc_pathname)
        File.open(desc_pathname) do |file|
          string = "<?xml version=\"1.0\"?><xml>#{file.readlines}</xml>"
          doc = Nokogiri::XML(string)
          doc.xpath('/xml/*').each do |node|
            element = DCElement.new(
                name: TAG_DC_MAP[node.name[0..2]], value: node.text)
            collection.elements << element unless element.value.empty?
          end
        end
      elsif File.exists?(catalog_pathname)
        # Not all collections have a colldesc.txt file, so use the catalog.txt
        # file (which contains only the collection's name) as a fallback.
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
      else
        collection.elements << DCElement.new(
            name: 'title', value: "CONTENTdm collection (#{collection.alias})")
      end
      collection
    end

    ##
    # @return The value of the collection's DC title element
    #
    def name
      element = self.elements.select{ |e| e.name == 'title' }.first
      element ? element.value : nil
    end

    def slug
      self.alias
    end

  end

end
