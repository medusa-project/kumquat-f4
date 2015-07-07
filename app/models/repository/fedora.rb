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
      # TODO: get a list of all node URIs from Solr and delete any that don't exist
      # In case we are coming in via rake, we have to reference all of our
      # model classes before ActiveRecord::Base.class_for_predicate will work
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
        begin
          instance = ActiveMedusa::Base.load(url)
          instance.reindex
        rescue
          # noop
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
