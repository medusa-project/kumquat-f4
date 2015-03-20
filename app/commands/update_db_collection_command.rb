class UpdateDBCollectionCommand < Command

  def initialize(collection, params)
    @collection = collection
    @params = params
  end

  def execute
    ActiveRecord::Base.transaction do
      if @params[:predicate_labels]
        @collection.rdf_predicates.destroy_all
        @params[:predicate_labels].each do |uri, label|
          @collection.rdf_predicates.build(uri: uri, label: label) unless label.blank?
        end
      else
        @collection.update(params)
      end
      @collection.save!
    end
  end

  def object
    @collection
  end

  def required_permissions
    super + [Permission::COLLECTIONS_UPDATE]
  end

end
