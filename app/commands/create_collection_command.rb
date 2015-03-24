class CreateCollectionCommand < Command

  def initialize(collection_params)
    @collection = Repository::Collection.new(collection_params)
    @collection.container_url = Kumquat::Application.kumquat_config[:fedora_url]
  end

  def execute
    @collection.save!
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::COLLECTIONS_CREATE]
  end

end
