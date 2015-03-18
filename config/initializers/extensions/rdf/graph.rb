module RDF

  ##
  # Reopen RDF::Graph to add some useful methods.
  #
  class Graph

    ##
    # Deletes all statements with the given predicate.
    #
    # @param predicate string or RDF::URI
    #
    def delete_predicate(predicate)
      delete_statements = RDF::Graph.new
      self.each_statement do |statement|
        delete_statements << statement if
            statement.predicate.to_s == predicate.to_s
      end
      self.delete(delete_statements)
    end

    ##
    # Returns any object corresponding to the given predicate.
    #
    # @param predicate string or RDF::URI
    # @return string, RDF::URI, or nil
    #
    def any_object(predicate)
      self.each_statement do |statement|
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
      self.each_statement do |statement|
        out_graph << statement if statement.predicate.to_s.end_with?(predicate)
      end
      out_graph
    end

  end

end