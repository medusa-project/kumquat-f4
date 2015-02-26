module Solr

  class Solr

    def initialize
      @http = HTTPClient.new
      @url = Kumquat::Application.kumquat_config[:solr_url].chomp('/')
    end

    def commit
      @http.get(@url + '/update?commit=true')
    end

  end

end