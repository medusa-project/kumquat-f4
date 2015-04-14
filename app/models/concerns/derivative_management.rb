module DerivativeManagement

  extend ActiveSupport::Concern

  STATIC_IMAGE_SIZES = [256, 512, 1024]

  included do
    after_create :generate_derivatives
  end

  ##
  # Generates derivatives (such as reduced-size JPEG images) for an item,
  # using self.master_bytestream.upload_pathname as a source.
  #
  def generate_derivatives
    master = self.master_bytestream
    master = self.children.first.master_bytestream if !master and
        self.children.any?
    return unless master

    src = master.upload_pathname
    if src
      if self.is_image? or self.is_pdf?
        Rails.logger.debug("Generating derivatives for #{self.repository_url}")
        generate_derivatives_for_image(self, src)
      elsif self.is_video?
        Rails.logger.debug("Generating derivatives for #{self.repository_url}")
        generate_derivatives_for_video(self, src)
      else
        Rails.logger.debug("Skipping derivative generation for #{self.repository_url}")
      end
    end
  end

  ##
  # Returns the path at which an item's image is expected to reside.
  #
  # @param size int One of STATIC_IMAGE_SIZES
  # @return string
  #
  def derivative_image_url(size)
    bs = self.bytestreams.
        select{ |bs| (bs.width == size and bs.height <= size) or
        (bs.height == size and bs.width <= size) }.first
    bs ? bs.public_repository_url : nil
  end

  private

  def generate_derivatives_for_image(item, src)
    STATIC_IMAGE_SIZES.each do |size|
      tempfile = Tempfile.new("deriv-#{size}")

      # read the source image and write the derivative to a temp file
      system "convert \"#{src}[0]\" -quality 70 -flatten -strip "\
      "-interlace Plane -alpha off -resize #{size}x#{size} "\
      "#{tempfile.path}.jpg"

      if File.exist?(tempfile.path + '.jpg')
        # create a new Bytestream using the temp file as a source
        bs = Repository::Bytestream.new(
            owner: item,
            upload_pathname: tempfile.path + '.jpg',
            media_type: 'image/jpeg',
            type: Repository::Bytestream::Type::DERIVATIVE,
            transaction_url: self.transaction_url)
        bs.save
        item.bytestreams << bs
      end
      File.delete(tempfile.path + '.jpg') if File.exist?(tempfile.path + '.jpg')
      tempfile.unlink
    end
  end

  def generate_derivatives_for_video(item, src)
    STATIC_IMAGE_SIZES.each do |size|
      tempfile = Tempfile.new("deriv-#{size}")
      begin
        system "ffmpeg -i \"#{src}\" -vframes 1 -an -vf "\
        "scale=\"min(#{size}\\, iw):-1\" -y \"#{tempfile.path}.jpg\""

        if File.exist?(tempfile.path + '.jpg')
          # create a new Bytestream using the temp file as a source
          bs = Repository::Bytestream.new(
              owner: item,
              upload_pathname: tempfile.path + '.jpg',
              media_type: 'image/jpeg',
              type: Repository::Bytestream::Type::DERIVATIVE,
              transaction_url: self.transaction_url)
          bs.save
          item.bytestreams << bs
        end
      ensure
        File.delete(tempfile.path + '.jpg') if File.exist?(tempfile.path + '.jpg')
        tempfile.unlink
      end
    end
  end

end
