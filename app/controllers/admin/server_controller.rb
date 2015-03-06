module Admin

  class ServerController < ControlPanelController

    def index
    end

    ##
    # Responds to GET /admin/server/image-server-status with either HTTP 200
    # or 503
    #
    def image_server_status
      http = HTTPClient.new
      begin
        response = http.get(Kumquat::Application.kumquat_config[:loris_url])
        if response.body.include?('Internet Imaging Protocol Server')
          render text: 'online'
        else
          render text: 'offline', status: 503
        end
      rescue
        render text: 'offline', status: 503
      end
    end

    ##
    # Responds to GET /admin/server/repository-status with either HTTP 200 or
    # 503
    #
    def repository_status
      http = HTTPClient.new
      begin
        response = http.get(Kumquat::Application.kumquat_config[:fedora_url])
        if response.status == 200
          render text: 'online'
        else
          render text: 'offline', status: 503
        end
      rescue
        render text: 'offline', status: 503
      end
    end

    ##
    # Responds to GET /admin/server/search-server-status with either HTTP 200
    # or 503
    #
    def search_server_status
      solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
      begin
        solr.get('select', params: { q: '*:*', start: 0, rows: 1 })
      rescue RSolr::Error::Http
        render text: 'offline', status: 503
      else
        render text: 'online'
      end
    end

    ##
    # Responds to PATCH /admin/server/commit
    #
    def commit
      begin
        Solr::Solr.new.commit
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Index updated.'
      end
      redirect_to :back
    end

  end

end
