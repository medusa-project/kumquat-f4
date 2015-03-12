module ImageServing

  extend ActiveSupport::Concern

  def image_iiif_url
    url = nil
    bs = self.master_image
    if bs
      config = Kumquat::Application.kumquat_config
      bs_path = bs.repository_url.gsub(config[:fedora_url], '').chomp('/')
      iiif_url = config[:iiif_url].chomp('/')
      url = "#{iiif_url}/#{bs_path}"
    end
    url
  end

  ##
  # @param width int Max width
  # @param height int
  #
  def image_url(width = nil, height = nil)
    url = nil
    bs = self.master_image
    if bs
      config = Kumquat::Application.kumquat_config
      bs_path = bs.repository_url.gsub(config[:fedora_url], '').chomp('/')
      iiif_url = config[:iiif_url].chomp('/')
      if width or height
        url = "#{iiif_url}/#{bs_path}/full/#{width},#{height}/0/default.jpg"
      else
        url = "#{iiif_url}/#{bs_path}/full/full/0/default.jpg"
      end
    end
    url
  end

end
