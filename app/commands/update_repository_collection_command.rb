class UpdateRepositoryCollectionCommand < Command

  def self.required_permissions
    super + [Permission::COLLECTIONS_UPDATE]
  end

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

end
