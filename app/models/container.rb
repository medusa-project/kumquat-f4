class Container < FedoraResource

  attr_reader :items

  def initialize(params = {})
    @items = []
    super(params)
  end

  def json_ld_representation=(json_ld)
    super(json_ld)
    # populate items
    struct = JSON.parse(json_ld).select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end
    struct[0]['http://www.w3.org/ns/ldp#contains'].each do |node|
      @items << Item.new(fedora_url: node['@id'])
    end
  end

end
