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
    Item.new(response.body)
  end

end
