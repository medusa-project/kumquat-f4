module ImageServing

  extend ActiveSupport::Concern

  ##
  # Returns the IIIF URL of the item.
  #
  # @return string
  #
  def image_iiif_url
    url = nil
    if self.respond_to?(:master_image)
      bs = self.master_image
      if bs
        config = Kumquat::Application.kumquat_config
        bs_path = bs.repository_url.gsub(config[:fedora_url], '').chomp('/')
        iiif_url = config[:iiif_url].chomp('/')
        url = "#{iiif_url}/#{bs_path}"
      end
    end
    url
  end

  ##
  # Returns the IIIF image server URL of an image scaled to fit the given
  # dimensions.
  #
  # @param width int Max width
  # @param height int Max height
  # @return string
  #
  def image_url(width = nil, height = nil)
    url = nil
    bs = self.master_bytestream
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
