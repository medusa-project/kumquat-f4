class BytestreamsController < WebsiteController

  include ActionController::Live

  ##
  # Responds to GET /bytestreams/:id
  #
  def show
    bs = Repository::Bytestream.find(params[:id])
    raise ActiveRecord::RecordNotFound, 'Bytestream not found' unless bs

    if bs and bs.repository_url
      repo_url = URI(bs.repository_url)
      Net::HTTP.start(repo_url.host, repo_url.port) do |http|
        request = Net::HTTP::Get.new(repo_url)
        http.request(request) do |res|
          response.content_type = bs.media_type if bs.media_type
          response.header['Content-Disposition'] =
              "attachment; filename=#{bs.filename || 'binary'}"
          res.read_body do |chunk|
            response.stream.write chunk
          end
        end
        response.stream.close
      end

      # The following is simpler but may be less efficient due to open() not
      # streaming its input
      #options = {}
      #options[:type] = bs.media_type if bs.media_type
      #options[:filename] = bs.filename if bs.filename
      #send_file(open(bs.repository_url), options)
    else
      render text: '404 Not Found', status: 404
    end
  end

end
