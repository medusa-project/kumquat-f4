class DeleteCollectionCommand < Command

  def self.required_permissions
    super + [Permission::COLLECTIONS_DELETE]
  end

  def initialize(collection)
    @collection = collection
  end

  def execute
    @collection.destroy!
  end

  def object
    @collection
  end

end
