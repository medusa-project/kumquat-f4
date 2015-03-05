##
# Abstract class from which several Kumquat entities inherit.
#
class Entity

  include ActiveModel::Model

  class Type
    BYTESTREAM = 'bytestream'
    COLLECTION = 'collection'
    ITEM = 'item'
  end

  ##
  # Namespace URI for application-specific metadata. Must end with a slash or
  # hash!
  #
  NAMESPACE_URI = 'http://example.org/' # TODO: fix and move

  @@http = HTTPClient.new
  @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

  attr_accessor :container_url # URL of the entity's parent container
  attr_accessor :fedora_json_ld
  attr_accessor :fedora_url
  attr_accessor :parent_uuid
  attr_accessor :solr_representation
  attr_accessor :triples
  attr_accessor :uuid
  attr_accessor :web_id

  validates :title, length: { minimum: 2, maximum: 200 }

  ##
  # @return ActiveKumquat::Entity
  #
  def self.all
    ActiveKumquat::Entity.new(self)
  end

  ##
  # @param uri Fedora resource URI
  # @return Entity
  #
  def self.find(uri) # TODO: rename to find_by_uri
    self.where(id: uri).first
  end

  ##
  # @param uuid string
  # @return Entity
  #
  def self.find_by_uuid(uuid)
    self.where(uuid: uuid).first
  end

  ##
  # @param web_id string
  # @return Entity
  #
  def self.find_by_web_id(web_id)
    self.where(kq_web_id: web_id).first
  end

  def self.method_missing(name, *args, &block)
    if [:count, :first, :limit, :order, :start, :where].include?(name.to_sym)
      ActiveKumquat::Entity.new(self).send(name, *args, &block)
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    [:first, :limit, :order, :start, :where].include?(method_name.to_sym)
  end

  def initialize(params = {})
    @fedora_json_ld = {}
    @triples = []

    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def delete(also_tombstone = false)
    url = self.fedora_url.chomp('/')
    @@http.delete(url)
    @@http.delete("#{url}/fcr:tombstone") if also_tombstone
  end

  ##
  # @param json JSON string
  # @return void
  #
  def fedora_json_ld=(json)
    @fedora_json_ld = JSON.parse(json.force_encoding('UTF-8'))
    struct = @fedora_json_ld.select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end

    self.uuid = struct[0]['http://fedora.info/definitions/v4/repository#uuid'].
        first['@value']
    if struct[0]["#{Entity::NAMESPACE_URI}webID"]
      self.web_id = struct[0]["#{Entity::NAMESPACE_URI}webID"].first['@value']
    end

    # populate triples
    self.triples = []
    struct[0].select{ |k, v| k[0] != '@' }.each do |k, v|
      v.each do |value|
        self.triples << Triple.new(predicate: k, object: value['@value'],
                                   type: value['@type'])
      end
    end

    # populate bytestreams
    struct[0].select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end
    if struct[0]['http://www.w3.org/ns/ldp#contains']
      struct[0]['http://www.w3.org/ns/ldp#contains'].each do |node|
        #@children << Bytestream.new(fedora_url: node['@id']) # TODO: fix this
      end
    end
  end

  def persisted?
    !self.web_id.blank?
  end

  ##
  # Persists the entity. For this to work, The entity must already have a URL
  # (e.g. fedora_url not nil), OR it must have a parent container URL (e.g.
  # container_url not nil).
  #
  # @raise RuntimeError if container_url and fedora_url are both nil.
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

  alias_method :save!, :save

  def subtitle
    t = self.triple('http://purl.org/dc/terms/alternative')
    t ? t.object : nil
  end

  def title
    t = self.triple('http://purl.org/dc/elements/1.1/title')
    t ? t.object : nil
  end

  def title=(title)
    self.triples.reject!{ |t| t.predicate.include?('/title') }
    self.triples << Triple.new(predicate: 'http://purl.org/dc/elements/1.1/title',
                               object: title) unless title.blank?
  end

  def to_param
    self.web_id
  end

  ##
  # Returns a single triple matching the predicate.
  #
  def triple(predicate)
    self.triples.select{ |e| e.predicate.include?(predicate) }.first
  end

  protected

  def fedora_metadata_url
    "#{self.fedora_url.chomp('/')}/fcr:metadata"
  end

  def make_indexable # TODO: get rid of this
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

end
