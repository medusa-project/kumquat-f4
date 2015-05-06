class PublishCollectionCommand < Command

  def self.required_permissions
    super + [Permission::PUBLISH_COLLECTIONS]
  end

  ##
  # @param collection Repository::Collection
  #
  def initialize(collection)
    @collection = collection
  end

  def execute
    ActiveKumquat::Base.transaction do
      @collection.published = true
      @collection.save!

      items = Repository::Item.where(Solr::Solr::COLLECTION_KEY_KEY => @collection.key)
      items.each do |item|
        item.published = true
        item.save!
      end
    end
  end

  def object
    @collection
  end

end
