class CreateCollectionCommand < Command

  def self.required_permissions
    super + [Permission::COLLECTIONS_CREATE]
  end

  def initialize(collection_params)
    @collection = Repository::Collection.new(collection_params)
    @collection.parent_url = Kumquat::Application.kumquat_config[:fedora_url]
  end

  def execute
    @collection.save!
  end

  def object
    @collection
  end

end
