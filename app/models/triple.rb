class Triple < ActiveRecord::Base

  belongs_to :metadata_profile, inverse_of: :triples

end
