class DeleteCollectionCommand < Command

  def initialize(collection)
    @collection = collection
  end

  def execute
    @collection.destroy!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::COLLECTIONS_DELETE]
  end

end
