module Describable

  extend ActiveSupport::Concern

  ##
  # Deletes all statements with the given predicate.
  #
  def delete_predicate(predicate)
    delete_statements = RDF::Graph.new
    self.rdf_graph.each_statement do |statement|
      delete_statements << statement if statement.predicate.to_s == predicate
    end
    self.rdf_graph.delete(delete_statements)
  end

  ##
  # @param statement RDF::Statement
  #
  def replace_statement(statement)
    g2 = RDF::Graph.new
    g2 << statement
    self.rdf_graph.delete(g2)
    self.rdf_graph << g2.statements.first
  end

  def subtitle
    self.rdf_graph.each_statement do |statement|
      return statement.object.to_s if
          statement.predicate.to_s == 'http://purl.org/dc/terms/alternative'
    end
    nil
  end

  def title
    self.rdf_graph.each_statement do |statement|
      return statement.object.to_s if
          statement.predicate.to_s == 'http://purl.org/dc/elements/1.1/title' or
              statement.predicate.to_s == 'http://purl.org/dc/terms/title'
    end
    nil
  end

  def title=(title)
    self.delete_predicate('http://purl.org/dc/elements/1.1/title')
    self.delete_predicate('http://purl.org/dc/terms/title')
    self.rdf_graph << RDF::Statement.new(
        subject: RDF::URI(),
        predicate: RDF::URI('http://purl.org/dc/elements/1.1/title'),
        object: title)  unless title.blank?
  end

  ##
  # Returns any object corresponding to the given predicate.
  #
  # @param predicate string or RDF::URI
  # @return string, RDF::URI, or nil
  #
  def any_object(predicate)
    self.rdf_graph.each_statement do |statement|
      return statement.object if statement.predicate.to_s.end_with?(predicate)
    end
    nil
  end

  ##
  # @param predicate string or RDF::URI
  # @return RDF::Graph
  #
  def statements_with_predicate(predicate)
    out_graph = RDF::Graph.new
    self.rdf_graph.each_statement do |statement|
      out_graph << statement if statement.predicate.to_s.end_with?(predicate)
    end
    out_graph
  end

end
