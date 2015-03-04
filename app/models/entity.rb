##
# Abstract class from which several Kumquat entities inherit.
#
class Entity

  include ActiveModel::Model

  ##
  # Namespace URI for application-specific metadata. Must end with a slash or
  # hash!
  #
  NAMESPACE_URI = 'http://example.org/' # TODO: fix

  @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

  delegate :fedora_json_ld, :fedora_url, :triples, :uuid, :web_id,
           to: :fedora_container

  attr_reader :fedora_container
  attr_accessor :solr_representation

  ##
  # @return ActiveKumquat::ResultSet
  #
  def self.all
    ActiveKumquat::Entity.new(self)
  end

  ##
  # @param uri Fedora resource URI
  # @return Entity
  #
  def self.find(uri) # TODO: rename to find_by_uri
    self.new(Fedora::Container.find(uri))
  end

  ##
  # @param uuid string
  # @return Entity
  #
  def self.find_by_uuid(uuid)
    response = @@solr.get('select', params: { q: "uuid:#{uuid}" })
    record = response['response']['docs'].first
    entity = nil
    if record
      entity = self.new(fedora_container: Fedora::Container.find(record['id']))
      entity.solr_representation = record if entity
    end
    entity
  end

  ##
  # @param web_id string
  # @return Entity
  #
  def self.find_by_web_id(web_id)
    response = @@solr.get('select', params: { q: "kq_web_id:#{web_id}" })
    record = response['response']['docs'].first
    entity = nil
    if record
      entity = self.new(fedora_container: Fedora::Container.find(record['id']))
      entity.solr_representation = record if entity
    end
    entity
  end

  def self.method_missing(name, *args, &block)
    if [:count, :first, :limit, :order, :start, :where].include?(name.to_sym)
      ActiveKumquat::Entity.new(self).send(name, *args, &block)
    end
  end

  ##
  # @return ActiveKumquat::ResultSet
  #
  def self.none
    ResultSet.new
  end

  def self.respond_to_missing?(method_name, include_private = false)
    [:first, :limit, :order, :start, :where].include?(method_name.to_sym)
  end

  def initialize(params = {})
    params[:fedora_container] ||= Fedora::Container.new
    @fedora_container = params[:fedora_container]

    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  def save
    self.fedora_container.save
  end

  alias_method :save!, :save

  def subtitle
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/terms/alternative')
    end
    t.first ? t.first.value : nil
  end

  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : nil
  end

  def title=(title)
    self.triples.reject!{ |t| t.predicate.include?('/title') }
    self.triples << Triple.new(predicate: 'http://purl.org/dc/elements/1.1/title',
                               object: title) unless title.blank?
  end

  def to_param
    self.web_id
  end

  def triple(predicate)
    t = self.triples.select do |e|
      e.predicate.include?(predicate)
    end
    t.first ? t.first.value : nil
  end

end
