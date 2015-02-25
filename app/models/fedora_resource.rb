class FedoraResource

  extend ActiveModel::Naming

  @@http_client = HTTPClient.new

  attr_accessor :fedora_json_ld
  attr_accessor :fedora_url
  attr_accessor :solr_representation
  attr_accessor :triples
  attr_accessor :uuid

  ##
  # @param params Hash with available keys: :fedora_url, :json_ld
  #
  def initialize(params = {})
    @persisted = false
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
    @@http_client.delete(self.fedora_url)
  end

  def fedora_json_ld=(json)
    @fedora_json_ld = json
    struct = JSON.parse(json).select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
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
    @persisted = true
  end

  def persisted?
    @persisted
  end

  def subtitle
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/terms/alternative')
    end
    t.first ? t.first.value : nil
  end

  ##
  # @see subtitle
  #
  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : 'Untitled'
  end

  def to_model
    self
  end

  def to_param
    self.uuid
  end

end
