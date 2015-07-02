module Repository

  class Fedora

    # Predicate URIs that start with any of these are repository-managed.
    MANAGED_PREDICATES = [
        'http://fedora.info/definitions/',
        'http://www.jcp.org/jcr',
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        'http://www.w3.org/2000/01/rdf-schema#',
        'http://www.w3.org/ns/ldp#'
    ]

    def reindex
      # we have to reference all of our model classes before
      # ActiveRecord::Base.class_for_predicate will work
      [Item, Collection, Bytestream]
      index_node(ActiveMedusa::Configuration.instance.fedora_url)
    end

    private

    ##
    # Recursive method that indexes the node at the given URL and all of its
    # children.
    #
    # @param url [String]
    #
    def index_node(url)
      graph = fetch_graph(url)
      class_uri = graph.any_object(ActiveMedusa::Configuration.
                                       instance.class_predicate)
      if class_uri
        # TODO: move this into ActiveMedusa::Base.from_url
        class_ = ActiveMedusa::Base.class_of_predicate(class_uri.to_s)
        if class_
          instance = class_.new
          instance.repository_url = url
          instance.reload!
          instance.reindex
        end
      end

      # index its children
      graph.each_statement do |st|
        if st.predicate.to_s == 'http://www.w3.org/ns/ldp#contains'
          index_node(st.object.to_s)
        end
      end

      Solr::Solr.client.commit
    end

    def fetch_graph(url)
      http = ActiveMedusa::Fedora.client
      response = http.get(url + '/fcr:metadata', nil,
                          { 'Accept' => 'application/n-triples' })
      graph = RDF::Graph.new
      graph.from_ntriples(response.body)
      graph
    end

  end

end
