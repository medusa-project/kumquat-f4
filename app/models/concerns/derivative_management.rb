module DerivativeManagement

  extend ActiveSupport::Concern

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
    after_create :generate_derivatives
  end

  ##
  # Updates an item's derivative bytestreams (such as reduced-size JPEG images),
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
      elsif self.is_audio?
        generate_derivatives_for_audio(self, src)
      else
        Rails.logger.debug("Skipping derivative generation for #{self.repository_url}")
      end
    end
  end

  ##
  # Returns the path at which an item's image is expected to reside.
  #
  # @param size int One of the sizes in IMAGE_DERIVATIVES
  # @param shape One of the Repository::Bytestream::Shape constants
  # @return string
  #
  def derivative_image_url(size, shape)
    bs = self.bytestreams.
        select{ |bs| (bs.width == size and bs.height <= size) or (bs.height == size and bs.width <= size) }.
        select{ |bs| bs.shape == shape }.first
    bs ? bs.public_repository_url : nil
  end

  private

  def generate_aspect_fit_derivatives_for_image(item, src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"

      # read the source image and write the derivative to a temp file
      system "convert \"#{src}[0]\" -quality #{profile[:quality]} -flatten "\
      "-strip -interlace Plane -alpha off "\
      "-resize #{profile[:size]}x#{profile[:size]} \"#{upload_pathname}\""

      if File.exist?(upload_pathname)
        # create a new Bytestream using the temp file as a source
        bs = Repository::Bytestream.new(
            owner: item,
            upload_pathname: upload_pathname,
            media_type: profile[:media_type],
            shape: Repository::Bytestream::Shape::ORIGINAL,
            type: Repository::Bytestream::Type::DERIVATIVE,
            transaction_url: self.transaction_url)
        bs.save
        item.bytestreams << bs
      end
      File.delete(upload_pathname) if File.exist?(upload_pathname)
      tempfile.unlink
    end
  end

  def generate_aspect_fit_image_derivatives_for_video(item, src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"
      begin
        system "ffmpeg -i \"#{src}\" -vframes 1 -an -vf -loglevel fatal "\
        "scale=\"min(#{profile[:size]}\\, iw):-1\" -y \"#{upload_pathname}\""

        if File.exist?(upload_pathname)
          # create a new Bytestream using the temp file as a source
          bs = Repository::Bytestream.new(
              owner: item,
              upload_pathname: upload_pathname,
              media_type: profile[:media_type],
              shape: Repository::Bytestream::Shape::ORIGINAL,
              type: Repository::Bytestream::Type::DERIVATIVE,
              transaction_url: self.transaction_url)
          bs.save
          item.bytestreams << bs
        end
      ensure
        File.delete(upload_pathname) if File.exist?(upload_pathname)
        tempfile.unlink
      end
    end
  end

  ##
  # @param item Repository::Item
  # @param src Path to source master audio file
  #
  def generate_derivatives_for_audio(item, src)
    # TODO: write this
  end

  ##
  # @param item Repository::Item
  # @param src Path to source master image
  #
  def generate_derivatives_for_image(item, src)
    generate_aspect_fit_derivatives_for_image(item, src)
    generate_square_derivatives_for_image(item, src)
  end

  ##
  # @param item Repository::Item
  # @param src Path to source master video
  #
  def generate_derivatives_for_video(item, src)
    generate_video_derivatives_for_video(item, src)
    generate_image_derivatives_for_video(item, src)
  end

  def generate_square_derivatives_for_image(item, src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"

      # read the source image and write the derivative to a temp file
      system "convert \"#{src}[0]\" "\
      "-define jpeg:size=#{profile[:size] * 2}x#{profile[:size] * 2} "\
      "-thumbnail #{profile[:size]}x#{profile[:size]}^ -alpha off "\
      "-quality #{profile[:quality]} -flatten -strip -interlace Plane "\
      "-gravity center "\
      "-extent #{profile[:size]}x#{profile[:size]} \"#{upload_pathname}\""

      if File.exist?(upload_pathname)
        # create a new Bytestream using the temp file as a source
        bs = Repository::Bytestream.new(
            owner: item,
            upload_pathname: upload_pathname,
            media_type: profile[:media_type],
            shape: Repository::Bytestream::Shape::SQUARE,
            type: Repository::Bytestream::Type::DERIVATIVE,
            transaction_url: self.transaction_url)
        bs.save
        item.bytestreams << bs
      end
      File.delete(upload_pathname) if File.exist?(upload_pathname)
      tempfile.unlink
    end
  end

  def generate_square_image_derivatives_for_video(item, src)
    IMAGE_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"
      begin
        system "ffmpeg -i \"#{src}\" -vframes 1 -an "\
        "-vf \"crop=ih:ih, scale=#{profile[:size]}:ih*#{profile[:size]}/iw\" "\
        "-y \"#{upload_pathname}\""

        if File.exist?(upload_pathname)
          # create a new Bytestream using the temp file as a source
          bs = Repository::Bytestream.new(
              owner: item,
              upload_pathname: upload_pathname,
              media_type: profile[:media_type],
              shape: Repository::Bytestream::Shape::SQUARE,
              type: Repository::Bytestream::Type::DERIVATIVE,
              transaction_url: self.transaction_url)
          bs.save
          item.bytestreams << bs
        end
      ensure
        File.delete(upload_pathname) if File.exist?(upload_pathname)
        tempfile.unlink
      end
    end
  end

  def generate_video_derivatives_for_video(item, src)
    VIDEO_DERIVATIVES.each do |profile|
      tempfile = Tempfile.new("deriv-#{profile[:size]}")
      upload_pathname = "#{tempfile.path}.#{profile[:extension]}"
      begin
        system "ffmpeg -i \"#{src}\" -loglevel fatal "\
        "-acodec #{profile[:audio_codec]} -ab #{profile[:audio_bitrate]}k "\
        "-c:v #{profile[:video_codec]} -b:v #{profile[:video_bitrate]}k "\
        "-vf scale=#{profile[:size]}:-1 \"#{upload_pathname}\""

        if File.exist?(upload_pathname)
          # create a new Bytestream using the temp file as a source
          bs = Repository::Bytestream.new(
              owner: item,
              upload_pathname: upload_pathname,
              media_type: profile[:media_type],
              shape: Repository::Bytestream::Shape::ORIGINAL,
              type: Repository::Bytestream::Type::DERIVATIVE,
              transaction_url: self.transaction_url)
          bs.save
          item.bytestreams << bs
        end
      ensure
        File.delete(upload_pathname) if File.exist?(upload_pathname)
        tempfile.unlink
      end
    end
  end

  def generate_image_derivatives_for_video(item, src)
    generate_aspect_fit_image_derivatives_for_video(item, src)
    generate_square_image_derivatives_for_video(item, src)
  end

end
