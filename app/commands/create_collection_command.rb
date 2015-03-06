class CreateCollectionCommand < Command

  def initialize(collection_params)
    @collection = Collection.new(collection_params)
    @collection.container_url = Kumquat::Application.kumquat_config[:fedora_url]
    @collection.web_id = collection_params[:key]
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
