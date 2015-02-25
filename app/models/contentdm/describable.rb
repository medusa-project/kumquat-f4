module Contentdm

  module Describable

    attr_accessor :elements # array of Elements

    def initialize
      self.elements = []
    end

    ##
    # @param f4_json_structure JSON-LD structure in which to embed the
    # object's metadata
    # @return JSON string
    #
    def to_json_ld(f4_json_structure = nil)
      f4_json_structure = [] unless f4_json_structure
      f4_metadata = f4_json_structure.
          select{ |h| h['@id'] == "#{self.fedora_url}/fcr:metadata" }.first
      unless f4_metadata
        f4_metadata = { '@id' => "#{self.fedora_url}/fcr:metadata" }
        f4_json_structure << f4_metadata
      end

      f4_metadata['@context'] = {} unless f4_metadata.keys.include?('@context')

      self.elements.each do |element|
        element_name = element.name ? element.name : 'unmapped'
        f4_metadata['@context'][element.namespace_prefix] = element.namespace_uri
        f4_metadata["#{element.namespace_prefix}:#{element_name}"] = element.value
      end

      JSON.pretty_generate(f4_json_structure)
    end

  end

end
