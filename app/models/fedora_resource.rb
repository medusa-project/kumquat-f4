class FedoraResource

  extend ActiveModel::Naming

  attr_accessor :fedora_uri
  attr_accessor :json_ld_representation
  attr_accessor :solr_representation
  attr_accessor :triples
  attr_accessor :uuid

  def initialize(fedora_json_ld = nil)
    @persisted = false
    self.json_ld_representation = fedora_json_ld
  end

  def json_ld_representation=(json)
    @json_ld_representation = json
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
