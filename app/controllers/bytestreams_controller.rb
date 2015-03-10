class BytestreamsController < ApplicationController

  ##
  # Responds to GET /items/:web_id/bytestreams/:uuid
  #
  def show
    bytestream = Bytestream.find(params[:uuid])
    redirect_to bytestream.fedora_url
  end

end