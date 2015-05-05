class RDFStreamer

  ##
  # @param describables ActiveKumquat::Entity of Describable objects
  # @param format One of :jsonld, :ttl, or :rdf
  def initialize(describables, format)
    @describables = describables
    @format = format
  end

  def each
    @describables.each do |d|
      case @format
        when :jsonld
          yield d.rdf_graph.to_jsonld
        when :rdf
          yield d.rdf_graph.to_rdfxml
        when :ttl
          yield d.rdf_graph.to_ttl
      end

    end
  end

end
