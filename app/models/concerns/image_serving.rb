module ImageServing

  extend ActiveSupport::Concern

  ##
  # @param width int Max width
  # @param height int
  #
  def image_url(width = nil, height = nil)
    url = nil
    bs = self.bytestreams.select{ |b| b.type == Bytestream::Type::MASTER }.first
    if bs
      bs_path = bs.repository_url.
          gsub(Kumquat::Application.kumquat_config[:fedora_url], '').chomp('/')
      iiif_url = Kumquat::Application.kumquat_config[:iiif_url].chomp('/')
      if width or height
        url = "#{iiif_url}/#{bs_path}/full/#{width},#{height}/0/default.jpg"
      else
        url = "#{iiif_url}/#{bs_path}/full/full/0/default.jpg"
      end
    end
    url
  end

end
