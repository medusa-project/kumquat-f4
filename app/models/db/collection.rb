module DB

  class Collection < ActiveRecord::Base

    has_many :rdf_predicates, :class_name => 'DB::RDFPredicate'
    belongs_to :theme, :class_name => 'Theme'

    validates :key, length: { minimum: 2, maximum: 20 }

    self.table_name = 'collections'

    def to_param
      self.key
    end

  end

end
