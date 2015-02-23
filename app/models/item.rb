class Item < FedoraResource

  attr_reader :bytestreams

  def initialize(fedora_json_ld)
    @bytestreams = []
    super(fedora_json_ld)
  end

  def json_ld_representation=(json_ld)
    super(json_ld)
    # populate bytestreams
    struct = JSON.parse(json_ld).select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end
    struct[0]['http://www.w3.org/ns/ldp#contains'].each do |node|
      @bytestreams << Bytestream.new(fedora_uri: node['@id'])
    end
  end

end
