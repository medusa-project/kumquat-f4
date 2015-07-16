##
# Renders RDF to represent result sets.
#
class RDFWriter

  include Rails.application.routes.url_helpers

  ##
  # @param results [ActiveMedusa::Relation<Repository::Item>]
  # @param format [Symbol] One of :jsonld, :ttl, or :rdf
  # @param subject_uri [String]
  # @param host [String]
  # @param port [Integer]
  #
  def initialize(results, format, subject_uri, host, port)
    @results = results
    @format = format
    @subject_uri = subject_uri
    @host = host
    @port = port
  end

  def to_s
    graph = RDF::Graph.new
    @results.each do |item|
      graph << [RDF::URI(@subject_uri),
                RDF::URI('http://sindice.com/vocab/search#result'),
                RDF::URI(repository_item_url(item, host: @host, port: @port))]
    end
    case @format
      when :jsonld
        return graph.to_jsonld
      when :rdfxml
        return graph.to_rdfxml
      when :ttl
        return graph.to_ttl
    end
  end

end
