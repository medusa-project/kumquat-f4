module DB

  class URIPrefix < ActiveRecord::Base

    validates :prefix, length: { minimum: 1, maximum: 30 },
              uniqueness: { case_sensitive: false }
    validates :uri, length: { minimum: 4 },
              uniqueness: { case_sensitive: false }

    self.table_name = 'uri_prefixes'

  end

end
