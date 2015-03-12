module BytestreamOwner

  def is_image?
    bs = self.master_bytestream
    bs and bs.media_type and bs.media_type.start_with?('image/')
  end

  def master_bytestream
    self.bytestreams.select{ |b| b.type == Bytestream::Type::MASTER }.first
  end

  def master_image
    self.is_image? ? self.master_bytestream : nil
  end

end
