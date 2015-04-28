class PublishCollectionCommand < Command

  ##
  # @param collection Repository::Collection
  #
  def initialize(collection)
    @collection = collection
  end

  def execute
    @collection.published = true
    @collection.save!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::PUBLISH_COLLECTIONS]
  end

end
