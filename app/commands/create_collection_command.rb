class CreateCollectionCommand < Command

  def initialize(collection_params)
    @collection = Collection.new(collection_params)
  end

  def execute
    @collection.save!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::COLLECTIONS_CREATE]
  end

end
