module Derivable

  extend ActiveSupport::Concern

  ##
  # A list of image media types for which we can presume to be able
  # to generate derivatives. This will be a subset of
  # TYPES_WITH_IMAGE_DERIVATIVES.
  #
  DERIVABLE_IMAGE_TYPES = %w(gif jp2 jpg png tif).map do |ext| # TODO: there are more than this
    MIME::Types.of(ext).map{ |type| type.to_s }
  end

  ##
  # A list of media types for which we can expect that image
  # derivatives will be available. This will be a superset of
  # DERIVABLE_IMAGE_TYPES.
  #
  TYPES_WITH_IMAGE_DERIVATIVES = DERIVABLE_IMAGE_TYPES +
      %w(video/mpeg video/quicktime video/mp4) # TODO: there are more than this

  IMAGE_DERIVATIVES = [ # sizes are scale-to-fit
      {
          extension: 'jpg',
          media_type: 'image/jpeg',
          size: 256,
          quality: 70
      },
      {
          extension: 'jpg',
          media_type: 'image/jpeg',
          size: 512,
          quality: 70
      },
      {
          extension: 'jpg',
          media_type: 'image/jpeg',
          size: 1024,
          quality: 70
      }
  ]
  VIDEO_DERIVATIVES = [ # sizes are scale-to-fit
      {
          audio_codec: 'libvorbis',
          audio_bitrate: 64,
          video_codec: 'vp8',
          video_bitrate: 1500,
          extension: 'webm',
          media_type: 'video/webm',
          size: 480
      }
  ]

  included do
    before_create :generate_derivatives
  end

  ##
  # Updates a master bytestream's derivative bytestreams (such as reduced-size
  # JPEG images), using `upload_pathname` as a source.
  #
  def generate_derivatives
    if self.type == Repository::Bytestream::Type::MASTER
      src = self.upload_pathname
      if src
        if self.is_image? or self.is_pdf?
          Rails.logger.debug("Generating derivatives for #{src}")
          generate_derivatives_for_image(src)
        elsif self.is_video?
          Rails.logger.debug("Generating derivatives for #{src}")
          generate_derivatives_for_video(src)
        elsif self.is_audio?
          Rails.logger.debug("Generating derivatives for #{src}")
          generate_derivatives_for_audio(src)
        else
          Rails.logger.debug("Skipping derivative generation for #{src}")
        end
      end
    end
  end

  private

  def generate_aspect_fit_derivatives_for_image(src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"

      # read the source image and write the derivative to a temp file
      system "convert \"#{src}[0]\" -quality #{profile[:quality]} -flatten "\
      "-strip -interlace Plane -alpha off "\
      "-resize #{profile[:size]}x#{profile[:size]} \"#{upload_pathname}\""

      if File.exist?(upload_pathname)
        # create a new Bytestream using the temp file as a source
        Repository::Bytestream.create!(
            upload_pathname: upload_pathname,
            parent_url: self.item.repository_url,
            item: self.item,
            shape: Repository::Bytestream::Shape::ORIGINAL,
            type: Repository::Bytestream::Type::DERIVATIVE,
            media_type: profile[:media_type],
            transaction_url: self.transaction_url)
      end
      File.delete(upload_pathname) if File.exist?(upload_pathname)
      tempfile.unlink
    end
  end

  def generate_aspect_fit_image_derivatives_for_video(src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"
      begin
        system "ffmpeg -i \"#{src}\" -vframes 1 -an -vf -loglevel fatal "\
        "scale=\"min(#{profile[:size]}\\, iw):-1\" -y \"#{upload_pathname}\""

        if File.exist?(upload_pathname)
          # create a new Bytestream using the temp file as a source
          Repository::Bytestream.create!(
              upload_pathname: upload_pathname,
              parent_url: self.item.repository_url,
              item: self.item,
              shape: Repository::Bytestream::Shape::ORIGINAL,
              type: Repository::Bytestream::Type::DERIVATIVE,
              media_type: profile[:media_type],
              transaction_url: self.transaction_url)
        end
      ensure
        File.delete(upload_pathname) if File.exist?(upload_pathname)
        tempfile.unlink
      end
    end
  end

  ##
  # @param src [String] Path to source master audio file
  #
  def generate_derivatives_for_audio(src)
    # TODO: write this
  end

  ##
  # @param src [String] Path to source master image
  #
  def generate_derivatives_for_image(src)
    generate_aspect_fit_derivatives_for_image(src)
    generate_square_derivatives_for_image(src)
  end

  ##
  # @param src [String] Path to source master video
  #
  def generate_derivatives_for_video(src)
    generate_image_derivatives_for_video(src)
  end

  ##
  # @param src [String] Path to source master image
  #
  def generate_square_derivatives_for_image(src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"

      # read the source image and write the derivative to a temp file
      system "convert \"#{src}[0]\" "\
      "-quality #{profile[:quality]} -flatten -strip -interlace Plane "\
      "-define jpeg:size=#{profile[:size] * 2}x#{profile[:size] * 2} "\
      "-thumbnail #{profile[:size]}x#{profile[:size]}^ -alpha off "\
      "-gravity center "\
      "-extent #{profile[:size]}x#{profile[:size]} \"#{upload_pathname}\""

      if File.exist?(upload_pathname)
        # create a new Bytestream using the temp file as a source
        Repository::Bytestream.create!(
            upload_pathname: upload_pathname,
            media_type: profile[:media_type],
            parent_url: self.item.repository_url,
            item: self.item,
            shape: Repository::Bytestream::Shape::SQUARE,
            type: Repository::Bytestream::Type::DERIVATIVE,
            transaction_url: self.transaction_url)
      end
      File.delete(upload_pathname) if File.exist?(upload_pathname)
      tempfile.unlink
    end
  end

  ##
  # @param src [String] Path to source master video
  #
  def generate_square_image_derivatives_for_video(src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"
      begin
        system "ffmpeg -i \"#{src}\" -vframes 1 -an "\
        "-vf \"crop=ih:ih, scale=#{profile[:size]}:ih*#{profile[:size]}/iw\" "\
        "-y \"#{upload_pathname}\""

        if File.exist?(upload_pathname)
          # create a new Bytestream using the temp file as a source
          Repository::Bytestream.create!(
              upload_pathname: upload_pathname,
              media_type: profile[:media_type],
              parent_url: self.item.repository_url,
              item: self.item,
              shape: Repository::Bytestream::Shape::SQUARE,
              type: Repository::Bytestream::Type::DERIVATIVE,
              transaction_url: self.transaction_url)
        end
      ensure
        File.delete(upload_pathname) if File.exist?(upload_pathname)
        tempfile.unlink
      end
    end
  end

  ##
  # @param src [String] Path to source master video
  #
  def generate_image_derivatives_for_video(src)
    generate_aspect_fit_image_derivatives_for_video(src)
    generate_square_image_derivatives_for_video(src)
  end

end
