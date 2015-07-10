class UnpublishCollectionCommand < Command

  def self.required_permissions
    super + [Permission::UNPUBLISH_COLLECTIONS]
  end

  ##
  # @param collection [Repository::Collection]
  #
  def initialize(collection)
    @collection = collection
  end

  def execute
    ActiveMedusa::Base.transaction do
      @collection.published = false
      @collection.save!

      items = Repository::Item.where(Solr::Fields::COLLECTION => @collection)
      items.each_with_index do |item, index|
        item.published = false
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
