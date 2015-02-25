module Fedora

  class Bytestream < Resource

    attr_accessor :fedora_uri
    attr_accessor :media_type

    ##
    # @param container_url URL of the parent container
    # @param pathname Optional file to upload into a child binary resource
    # @param slug Optional URL slug
    # @param external_resource_url string
    # @return Bytestream
    #
    def self.create(container_url, slug = nil, pathname = nil,
                    external_resource_url = nil)
      slug_url = slug ? "#{container_url}/#{slug}" : container_url

      response = nil
      if pathname
        File.open(pathname) do |file|
          response = slug ? @@http.put(slug_url, file) :
              @@http.post(container_url, file)
        end
      elsif external_resource_url
        response = @@http.post(container_url, nil,
                              { 'Content-Type' => 'text/plain' })
        headers = { 'Content-Type' => "message/external-body; "\
          "access-type=URL; URL=\"#{external_resource_url}\"" }
        response = @@http.put(response.header['Location'].first, nil, headers)
      else
        response = slug ? @@http.put(slug_url) : @@http.post(container_url)
      end

      Bytestream.new(fedora_url: response.header['Location'].first)
    end

  end

end
