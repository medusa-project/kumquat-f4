class Item < FedoraResource

  attr_reader :bytestreams

  def initialize(params = {})
    @bytestreams = []
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
        @bytestreams << Bytestream.new(fedora_url: node['@id'])
      end
    end
  end

end
