module DB

  class Collection < ActiveRecord::Base

    belongs_to :metadata_profile
    belongs_to :theme

    validates :metadata_profile, presence: true
    validates :key, length: { minimum: 2, maximum: 20 }

    self.table_name = 'collections'

    def to_param
      self.key
    end

  end

end
