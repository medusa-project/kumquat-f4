##
# Abstract class from which several Kumquat entities inherit.
#
class Entity

  ##
  # Namespace URI for application-specific metadata. Must end with a slash or
  # hash!
  #
  NAMESPACE_URI = 'http://example.org/' # TODO: fix

  @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

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
    if [:first, :limit, :order, :start, :where].include?(name.to_sym)
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

end
