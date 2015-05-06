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

  end

end
