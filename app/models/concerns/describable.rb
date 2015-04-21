module Describable

  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  def description
    self.rdf_graph.each_statement do |statement|
      return statement.object.to_s if
          statement.predicate.to_s.end_with?('/description')
    end
    nil
  end

  ##
  # Returns the RDF graph of the item with various triples (such as
  # repository-managed ones etc.) filtered out.
  #
  # @param subject_uri string
  # @return RDF::Graph
  # @see rdf_graph
  #
  def public_rdf_graph(subject_uri)
    public_graph = RDF::Graph.new
    self.rdf_graph.each_statement do |statement|
      if !statement.predicate.to_s.start_with?('http://fedora.info/definitions') and
          !statement.predicate.to_s.start_with?('http://www.w3.org/1999/02/22-rdf-syntax-ns') and
          !statement.predicate.to_s.start_with?('http://www.w3.org/2000/01/rdf-schema') and
          !statement.predicate.to_s.start_with?('http://www.w3.org/ns/ldp') and
          !statement.predicate.to_s.start_with?(Kumquat::Application::NAMESPACE_URI)
        st = statement.dup
        st.subject = RDF::URI(subject_uri)
        public_graph << st
      end
    end
    public_graph
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
