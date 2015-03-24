module DerivativeManagement

  extend ActiveSupport::Concern

  BALANCED_TREE_LEVELS = 3
  DERIVATIVE_ROOT = File.join(Rails.root, 'public', 'derivatives')
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
    if src and (self.is_image? or self.is_pdf?)
      Rails.logger.debug("Generating derivatives for #{self.repository_url}")

      STATIC_IMAGE_SIZES.each do |size|
        tempfile = Tempfile.new("deriv-#{size}")
        begin
          # read the source image and write the derivative to a temp file
          input = Magick::Image.read(src).first
          output = input.resize_to_fit(size, size).strip!
          output.border!(0, 0, 'white') # for PDF
          output.alpha(Magick::DeactivateAlphaChannel) # for PDF
          output.write(tempfile.path + '.jpg') {
            self.quality = 70
            self.interlace = Magick::PlaneInterlace
          }
          #system "convert \"#{src}\" -quality 70 -strip "\
          #  "-interlace Plane -resize #{size}x#{size} #{dest}"

          # create a new Bytestream using the temp file as a source
          # TODO: use a FIFO instead of a temp file
          bs = Repository::Bytestream.new(
              owner: self,
              upload_pathname: tempfile.path + '.jpg',
              media_type: 'image/jpeg',
              type: Repository::Bytestream::Type::DERIVATIVE)
          bs.save
          self.bytestreams << bs
        rescue Magick::ImageMagickError => e
          # no need to log it since RMagick already does
        ensure
          tempfile.unlink
        end
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
        select{ |bs| bs.width == size or bs.height == size }.first
    bs ? bs.repository_url : nil
  end

end
