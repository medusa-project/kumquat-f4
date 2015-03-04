module Fedora

  ##
  # A container is a Fedora resource that may contain metadata and other
  # resources but cannot be associated with a bytestream.
  #
  class Container < Resource

    attr_accessor :collection_key
    attr_accessor :parent_uuid
    attr_accessor :web_id

    ##
    # @param parent_container_url URL of the parent container
    # @param slug Optional URL slug
    # @return Container
    #
    def self.create(parent_container_url, slug = nil)
      slug_url = slug ? "#{parent_container_url}/#{slug}" : parent_container_url
      response = slug ? @@http.put(slug_url) : @@http.post(parent_container_url)
      container = find(response.header['Location'].first)
      container.container_url = parent_container_url
      container
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
      if struct[0]["#{Entity::NAMESPACE_URI}collectionKey"]
        self.collection_key = struct[0]["#{Entity::NAMESPACE_URI}collectionKey"].first['@value']
      end
      if struct[0]["#{Entity::NAMESPACE_URI}parentUUID"]
        self.parent_uuid = struct[0]["#{Entity::NAMESPACE_URI}parentUUID"].first['@value']
      end
    end

    def make_indexable
      headers = { 'Content-Type' => 'application/sparql-update' }
      body = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
      'PREFIX indexing: <http://fedora.info/definitions/v4/indexing#> '\
      'DELETE { } '\
      'INSERT { '\
        "<> indexing:hasIndexingTransformation \"#{Fedora::Repository::TRANSFORM_NAME}\"; "\
        'rdf:type indexing:Indexable; } '\
      'WHERE { }'
      @@http.patch(self.fedora_metadata_url, body, headers)
    end

    ##
    # Persists the container. For this to work, the container must already have
    # a URL (e.g. fedora_url not nil), OR the container must have a parent
    # container URL (e.g. parent_container_url not nil).
    #
    # @raise RuntimeError if parent_container_url and fedora_url are both nil.
    #
    def save
      if self.fedora_url
        @@http.put(self.fedora_metadata_url, self.fedora_json_ld,
                   { 'Content-Type' => 'application/ld+json' })
      elsif self.container_url
        @@http.post(self.container_url, self.fedora_json_ld,
                    { 'Content-Type' => 'application/ld+json' })
      else
        raise RuntimeError 'Container has no URL.'
      end
      self.make_indexable
    end

  end

end
