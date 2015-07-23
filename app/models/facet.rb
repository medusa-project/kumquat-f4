class Facet < ActiveRecord::Base

  has_many :triples, inverse_of: :facet, dependent: :nullify

  validates :name, presence: true, length: { minimum: 2 },
            uniqueness: { case_sensitive: false }
  validates :solr_field, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :solr_field, with: /\w*_facet\b/ # must end with "_facet"

  def to_s
    self.name
  end

end
