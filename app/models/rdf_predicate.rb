class RDFPredicate < ActiveRecord::Base

  belongs_to :collection, class_name: 'DB::Collection'

  validates :label, length: { minimum: 2, maximum: 100 }
  validates :uri, length: { minimum: 4 }

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord unless self.deletable
  end

  ##
  # Returns the default label of the predicate; i.e. the label associated
  # with the predicate matching the URI of this instance that is not
  # associated with a collection.
  #
  # @return string
  #
  def default_label
    if self.collection
      predicate = RDFPredicate.where(uri: self.uri, collection_id: nil).first
      return predicate.label if predicate
    end
    self.label
  end

end
