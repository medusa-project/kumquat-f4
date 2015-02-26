module Fedora

  class Resource

    @@http = HTTPClient.new

    attr_accessor :fedora_json_ld
    attr_accessor :fedora_url
    attr_accessor :triples
    attr_accessor :uuid

    def initialize(params = {})
      @triples = []
      params.each do |k, v|
        if respond_to?("#{k}=")
          send "#{k}=", v
        else
          instance_variable_set "@#{k}", v
        end
      end
    end

    def delete
      @@http.delete(self.fedora_url)
    end

    def fedora_json_ld=(json)
      @fedora_json_ld = json
      struct = JSON.parse(json).select do |node|
        node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
      end

      if struct[0]['http://example.org/web_id']
        self.web_id = struct[0]['http://example.org/web_id'].first['@value'] # TODO: fix namespace
      end
      self.uuid = struct[0]['http://fedora.info/definitions/v4/repository#uuid'].first['@value']
      # populate triples
      self.triples = []
      struct[0].select{ |k, v| k[0] != '@' }.each do |k, v|
        v.each do |value|
          self.triples << Triple.new(predicate: k, object: value['@value'],
                                     type: value['@type'])
        end
      end
    end

    def fedora_metadata_url
      "#{self.fedora_url.chomp('/')}/fcr:metadata"
    end

  end

end
