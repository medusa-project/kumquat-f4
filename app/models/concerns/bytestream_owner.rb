module BytestreamOwner

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
    self.bytestreams.select{ |b| b.type == Bytestream::Type::MASTER }.first
  end

  def master_image
    self.is_image? ? self.master_bytestream : nil
  end

  def media_type
    bs = self.master_bytestream
    bs ? bs.media_type : nil
  end

end
