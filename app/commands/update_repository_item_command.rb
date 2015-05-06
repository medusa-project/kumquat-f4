class UpdateRepositoryItemCommand < Command

  def self.required_permissions
    super + [Permission::UPDATE_ITEMS]
  end

  def initialize(item, item_params)
    @item = item
    @item_params = item_params
  end

  def execute
    @item.update!(@item_params)
  end

  def object
    @item
  end

end
