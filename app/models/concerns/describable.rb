module Describable

  extend ActiveSupport::Concern

  def description
    self.rdf_graph.each_statement do |statement|
      return statement.object.to_s if
          statement.predicate.to_s.end_with?('/description')
    end
    nil
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
    self.rdf_graph.delete_predicate('http://purl.org/dc/elements/1.1/title')
    self.rdf_graph.delete_predicate('http://purl.org/dc/terms/title')
    self.rdf_graph << RDF::Statement.new(
        subject: RDF::URI(),
        predicate: RDF::URI('http://purl.org/dc/elements/1.1/title'),
        object: title)  unless title.blank?
  end

end
