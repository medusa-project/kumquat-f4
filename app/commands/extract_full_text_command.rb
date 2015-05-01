class ExtractFullTextCommand < Command

  def initialize(item)
    @item = item
  end

  def execute
    @item.extract_and_update_full_text
    @item.save!
  end

  def object
    @item
  end

  def required_permissions
    super + []
  end

end
