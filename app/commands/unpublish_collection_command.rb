class UnpublishCollectionCommand < Command

  ##
  # @param collection Repository::Collection
  #
  def initialize(collection)
    @collection = collection
  end

  def execute
    @collection.published = false
    @collection.save!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::UNPUBLISH_COLLECTIONS]
  end

end
