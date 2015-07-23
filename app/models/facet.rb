class Facet < ActiveRecord::Base

  has_many :triples, inverse_of: :facet, dependent: :nullify

  validates :name, presence: true

  def to_s
    self.name
  end

end
