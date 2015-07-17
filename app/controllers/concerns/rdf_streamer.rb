class RDFStreamer

  ##
  # @param describables [ActiveMedusa::Relation<Describable>]
  # @param format [Symbol] One of :jsonld, :ttl, or :rdf
  def initialize(describables, format)
    @describables = describables
    @format = format
  end

  def each
    case @format
      when :jsonld # TODO: this is broken
        yield 'opener'
        @describables.each { |d| yield d.rdf_graph.to_jsonld }
        yield 'bla'
      when :rdf # TODO: this is broken
        yield 'opener'
        @describables.each { |d| yield d.rdf_graph.to_rdfxml }
        yield 'bla'
      when :ttl
        @describables.each { |d| yield to_ttl_fragment(d.rdf_graph) }
    end
  end

  private

  def to_ttl_fragment(graph)
    ttl = ''
    graph.each_statement do |st|
      subject = "<#{st.subject.to_s}>"
      predicate = "<#{st.predicate.to_s}>"
      if st.object.kind_of?(RDF::URI)
        object = "<#{st.object.to_s}>"
      elsif st.object.to_s.lines.count > 1
        object = "\"\"\"#{st.object.to_s}\"\"\""
      else
        object = "\"#{st.object.to_s}\""
      end
      ttl += "#{subject} #{predicate} #{object} .\n"
    end
    ttl
  end

end
