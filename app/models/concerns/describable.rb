module Describable

  extend ActiveSupport::Concern

  included do
    attr_accessor :triples
  end

  def subtitle
    t = self.triple('http://purl.org/dc/terms/alternative')
    t ? t.object : nil
  end

  def title
    t = self.triple('http://purl.org/dc/elements/1.1/title')
    t ? t.object : nil
  end

  def title=(title)
    self.triples.reject!{ |t| t.predicate.include?('/title') }
    self.triples << Triple.new(predicate: 'http://purl.org/dc/elements/1.1/title',
                               object: title) unless title.blank?
  end

  ##
  # Returns a single triple matching the predicate.
  #
  def triple(predicate)
    self.triples.select{ |e| e.predicate.include?(predicate) }.first
  end

end