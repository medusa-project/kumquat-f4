module Fedora

  ##
  # A container is a Fedora resource that may contain metadata and other
  # resources but cannot be associated with a bytestream.
  #
  class Container < Resource

    attr_reader :children
    attr_accessor :web_id

    ##
    # @param container_url URL of the parent container
    # @param slug Optional URL slug
    # @return Container
    #
    def self.create(container_url, slug = nil)
      slug_url = slug ? "#{container_url}/#{slug}" : container_url
      response = slug ? @@http.put(slug_url) : @@http.post(container_url)
      find(response.header['Location'].first)
    end

    ##
    # @param uri Fedora resource URI
    # @return Container
    #
    def self.find(uri)
      response = @@http.get(uri, nil, { 'Accept' => 'application/ld+json' })
      item = Container.new(fedora_url: uri)
      item.fedora_json_ld = response.body
      item
    end

    def initialize(params = {})
      @children = []
      super(params)
    end

    def fedora_json_ld=(json_ld)
      super(json_ld)
      # populate bytestreams
      struct = JSON.parse(json_ld).select do |node|
        node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
      end
      if struct[0]['http://www.w3.org/ns/ldp#contains']
        struct[0]['http://www.w3.org/ns/ldp#contains'].each do |node|
          @children << Bytestream.new(fedora_url: node['@id']) # TODO: make this either a Bytestream or Container
        end
      end
    end

    def make_indexable
      url = "#{self.fedora_url}/fcr:metadata"
      headers = { 'Content-Type' => 'application/sparql-update' }
      body = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
      'PREFIX indexing: <http://fedora.info/definitions/v4/indexing#> '\
      'DELETE { } '\
      'INSERT { '\
        "<> indexing:hasIndexingTransformation \"#{Fedora::Repository::TRANSFORM_NAME}\"; "\
        'rdf:type indexing:Indexable; } '\
      'WHERE { }'
      @@http.patch(url, body, headers)
    end

  end

end
