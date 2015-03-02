module Fedora

  class Bytestream < Resource

    attr_accessor :external_resource_url
    attr_accessor :media_type

    ##
    # @param container Parent container
    # @param pathname Optional file to upload into a child binary resource
    # @param slug Optional URL slug
    # @param external_resource_url string
    # @return Bytestream
    #
    def self.create(container, slug = nil, pathname = nil,
                    external_resource_url = nil)
      slug_url = slug ? "#{container.fedora_url}/#{slug}" : container.fedora_url

      response = nil
      if pathname
        File.open(pathname) do |file|
          response = slug ? @@http.put(slug_url, file) :
              @@http.post(container.fedora_url, file)
        end
      elsif external_resource_url
        response = @@http.post(container.fedora_url, nil,
                              { 'Content-Type' => 'text/plain' })
        headers = { 'Content-Type' => "message/external-body; "\
          "access-type=URL; URL=\"#{external_resource_url}\"" }
        response = @@http.put(response.header['Location'].first, nil, headers)
      else
        response = slug ? @@http.put(slug_url) : @@http.post(container.fedora_url)
      end

      Bytestream.new(fedora_url: response.header['Location'].first,
                     container: container,
                     resource_type: ResourceType::BYTESTREAM)
    end

  end

end
