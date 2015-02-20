class Fedora4

  def initialize
    @http = HTTPClient.new
  end

  ##
  # @param resource_uri Fedora resource URI
  #
  def item(resource_uri)
    response = @http.get(resource_uri, nil, { 'Accept' => 'application/ld+json' })
    raise HTTPClient::BadResponseError, "GET #{resource_uri}: got response "\
          "#{response.status} #{response.reason}" if response.status >= 400
    Fedora4.item_from_json_ld(response.body)
  end

  private

  ##
  # @param json string
  # @return Item
  #
  def self.item_from_json_ld(json)
    struct = JSON.parse(json).select do |node|
      node['@type'] and node['@type'].include?('http://www.w3.org/ns/ldp#RDFSource')
    end
    item = Item.new
    # populate uuid
    item.uuid = struct[0]['http://fedora.info/definitions/v4/repository#uuid'].first['@value']
    # populate triples
    struct[0].select{ |k, v| k[0] != '@' }.each do |k, v|
      v.each do |value|
        item.triples << Triple.new(predicate: k, object: value['@value'])
      end
    end
    item
  end

end