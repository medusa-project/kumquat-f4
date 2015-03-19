module RDB

  class Collection < ActiveRecord::Base

    validates :key, length: { minimum: 2, maximum: 20 }

    self.table_name = 'collections'

  end

end
