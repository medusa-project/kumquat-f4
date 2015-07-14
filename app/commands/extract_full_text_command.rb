class ExtractFullTextCommand < Command

  def self.required_permissions
    super + []
  end

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

end
