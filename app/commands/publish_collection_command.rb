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

      items = Repository::Item.where(Solr::Fields::COLLECTION_KEY => @collection.key)
      items.each_with_index do |item, index|
        item.published = true
        item.save!
        if self.task and index % 10
          self.task.percent_complete = index / items.length.to_f
          self.task.save!
        end
      end
    end
  end

  def object
    @collection
  end

end
