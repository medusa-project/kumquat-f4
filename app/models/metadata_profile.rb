class MetadataProfile < ActiveRecord::Base

  include Defaultable
  include Introspection

  has_many :db_collections, inverse_of: :metadata_profile,
           class_name: 'DB::Collection', dependent: :restrict_with_error
  has_many :triples, inverse_of: :metadata_profile, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2 },
            uniqueness: { case_sensitive: false }

  ##
  # Overrides parent to intelligently clone a metadata profile including all
  # of its triples.
  #
  def dup
    clone = super
    self.triples.each { |t| clone.triples << t.dup }
    clone
  end

end
