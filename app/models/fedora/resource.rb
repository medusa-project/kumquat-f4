module Fedora

  class Resource

    @@http = HTTPClient.new

    attr_accessor :container_url # URL of the resource's parent container
    attr_accessor :fedora_json_ld
    attr_accessor :fedora_url
    attr_accessor :resource_type # one of the ResourceType constants
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
      self.container_url ||= Kumquat::Application.kumquat_config[:fedora_url]
    end

    def delete(also_tombstone = false)
      url = self.fedora_url.chomp('/')
      @@http.delete(url)
      @@http.delete("#{url}/fcr:tombstone") if also_tombstone
    end

    def fedora_json_ld=(json)
      @fedora_json_ld = json.force_encoding('UTF-8')
      struct = JSON.parse(json).select do |node|
        node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
      end

      if struct[0]["#{Entity::NAMESPACE_URI}webID"]
        self.web_id = struct[0]["#{Entity::NAMESPACE_URI}webID"].first['@value']
      end
      if struct[0]["#{Entity::NAMESPACE_URI}resourceType"]
        self.resource_type = struct[0]["#{Entity::NAMESPACE_URI}resourceType"].first['@value']
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
