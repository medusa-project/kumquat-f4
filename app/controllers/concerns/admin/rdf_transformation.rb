module Admin

  module RDFTransformation

    extend ActiveSupport::Concern

    ##
    # Returns the RDF graph of the item with various triples (such as
    # repository-managed ones etc.) filtered out.
    #
    # @param item Repository::Item
    # @return RDF::Graph
    # @see rdf_graph
    #
    def admin_rdf_graph_for(item)
      graph = RDF::Graph.new
      subject_uri = repository_item_url(item)
      item.rdf_graph.each_statement do |statement|
        if !statement.predicate.to_s.start_with?('http://fedora.info/definitions') and
            !statement.predicate.to_s.start_with?('http://www.w3.org/1999/02/22-rdf-syntax-ns') and
            !statement.predicate.to_s.start_with?('http://www.w3.org/2000/01/rdf-schema') and
            !statement.predicate.to_s.start_with?('http://www.w3.org/ns/ldp')
          st = statement.dup
          st.subject = RDF::URI(subject_uri)
          graph << st
        end
      end
      graph
    end

  end

end
