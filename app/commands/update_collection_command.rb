class UpdateCollectionCommand < Command

  def initialize(collection, collection_params)
    @collection = collection
    @collection.update(collection_params)
  end

  def execute
    @collection.save!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::COLLECTIONS_UPDATE]
  end

end
