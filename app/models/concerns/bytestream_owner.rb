module BytestreamOwner

  ##
  # Returns the path at which an item's image is expected to reside.
  #
  # @param size [Integer] One of the sizes in `IMAGE_DERIVATIVES`
  # @param shape [String] One of the `Repository::Bytestream::Shape` constants
  # @return [String]
  #
  def derivative_image_url(size, shape = Repository::Bytestream::Shape::ORIGINAL)
    bs = self.bytestreams. # TODO: rewrite this as a solr query
    select{ |bs| (bs.width == size and bs.height <= size) or (bs.height == size and bs.width <= size) }.
        select{ |bs| bs.shape == shape }.first
    bs ? bs.public_repository_url : nil
  end

  def is_audio?
    bs = self.master_bytestream
    bs and bs.is_audio?
  end

  def is_image?
    bs = self.master_bytestream
    bs and bs.is_image?
  end

  def is_pdf?
    bs = self.master_bytestream
    bs and bs.is_pdf?
  end

  def is_text?
    bs = self.master_bytestream
    bs and bs.is_text?
  end

  def is_video?
    bs = self.master_bytestream
    bs and bs.is_video?
  end

  def master_bytestream
    self.bytestreams.facet(false).
        where(Solr::Fields::BYTESTREAM_TYPE =>
                  Repository::Bytestream::Type::MASTER).first
  end

  def master_image
    self.is_image? ? self.master_bytestream : nil
  end

  def media_type
    bs = self.master_bytestream
    bs ? bs.media_type : nil
  end

end
