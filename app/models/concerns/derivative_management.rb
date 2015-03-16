module DerivativeManagement

  extend ActiveSupport::Concern

  BALANCED_TREE_LEVELS = 3
  DERIVATIVE_ROOT = File.join(Rails.root, 'public', 'derivatives')
  STATIC_IMAGE_SIZES = [512]

  included do
    before_save :generate_derivatives
    after_delete :delete_derivatives
  end

  ##
  # Deletes the static image associated with an item.
  #
  def delete_derivatives
    STATIC_IMAGE_SIZES.each do |size|
      path = self.image_path(size)
      if File.exists?(path)
        File.unlink(path)
        # delete the images' containing folders up to the first non-empty one
        path = DERIVATIVE_ROOT
        (0..BALANCED_TREE_LEVELS).step(2).each do |i|
          path = File.join(path, self.uuid[i..i + 1])
          FileUtils.rmdir(path) # rmdir will only delete empty folders
        end
      end
    end
  end

  ##
  # Generates a static image for an item. Currently only works with
  # upload_pathname as a source.
  #
  def generate_derivatives
    bytestream = self.master_bytestream
    bytestream = self.children.first.master_bytestream if !bytestream and
        self.children.any?
    if bytestream
      src = bytestream.upload_pathname
      if src and self.is_image?
        FileUtils.mkdir_p(self.derivative_path)
        STATIC_IMAGE_SIZES.each do |size|
          begin
            input = Magick::Image.read(src).first
            output = input.resize_to_fit(size, size).strip!
            output.write(self.image_path(size)) {
              self.quality = 70
              self.interlace = Magick::PlaneInterlace
            }
            #system "convert \"#{src}\" -quality 70 -strip "\
            #  "-interlace Plane -resize #{size}x#{size} #{dest}"
          rescue Magick::ImageMagickError => e
            # no need to log it since RMagick already does
          end
        end
      end
    end
  end

  ##
  # Returns the local path at which the item's derivatives are expected to reside.
  #
  # @return string
  #
  def derivative_path
    File.join(DERIVATIVE_ROOT, self.collection.key, tree_structure)
  end

  def public_derivative_path(root_path)
    File.join(root_path, 'derivatives', self.collection.key, tree_structure)
  end

  ##
  # Returns the path at which an item's image is expected to reside.
  #
  # @param size int One of STATIC_IMAGE_SIZES
  # @return string
  #
  def image_path(size = 512)
    File.join(self.derivative_path, image_filename(size))
  end

  ##
  # Returns the path at which an item's image is expected to reside.
  #
  # @param path string
  # @param size int One of STATIC_IMAGE_SIZES
  # @return string
  #
  def public_image_path(root_path, size = 512)
    File.join(self.public_derivative_path(root_path), image_filename(size))
  end

  private

  def image_filename(size)
    self.uuid + "-#{size}.jpg"
  end

  def tree_structure
    path = File::SEPARATOR
    (0..BALANCED_TREE_LEVELS).step(2).each do |i|
      path = File.join(path, self.uuid[i..i + 1])
    end
    path
  end

end
