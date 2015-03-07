module Describable

  extend ActiveSupport::Concern

  included do
    attr_accessor :triples
  end

  ##
  # Deletes all statements with the given predicate.
  #
  def delete_predicate(graph, predicate)
    delete_statements = RDF::Graph.new
    graph.each_statement do |statement|
      delete_statements << statement if statement.predicate.to_s == predicate
    end
    graph.delete(delete_statements)
  end

  ##
  # @param graph RDF::Graph
  # @param statement RDF::Statement
  #
  def replace_statement(graph, statement)
    g2 = RDF::Graph.new
    g2 << statement
    graph.delete(g2)
    graph << g2.statements.first
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