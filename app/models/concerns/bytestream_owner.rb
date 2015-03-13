module BytestreamOwner

  def is_audio?
    bs = self.master_bytestream
    bs and bs.media_type and bs.media_type.start_with?('audio/')
  end

  def is_image?
    bs = self.master_bytestream
    bs and bs.media_type and bs.media_type.start_with?('image/')
  end

  def is_pdf?
    bs = self.master_bytestream
    bs and bs.media_type and bs.media_type == 'application/pdf'
  end

  def is_video?
    bs = self.master_bytestream
    bs and bs.media_type and bs.media_type.start_with?('video/')
  end

  def master_bytestream
    self.bytestreams.select{ |b| b.type == Bytestream::Type::MASTER }.first
  end

  def master_image
    self.is_image? ? self.master_bytestream : nil
  end

end
