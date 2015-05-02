class UpdateRepositoryItemCommand < Command

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

  def required_permissions
    super + [Permission::UPDATE_ITEMS]
  end

end
