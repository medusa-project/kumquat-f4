module ActiveKumquat

  ##
  # Query builder class, conceptually similar to ActiveRecord::Relation.
  #
  class Entity

    @@http = HTTPClient.new
    @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

    attr_reader :solr_request

    def initialize(caller)
      @caller = caller
      @facet = true
      @facet_queries = []
      @limit = nil
      @loaded = false
      @order = nil
      @results = ResultSet.new
      @start = 0
      @where_clauses = [] # will be joined by AND
    end

    def count
      @start = 0
      @limit = 0
      self.to_a.total_length
    end

    ##
    # @param fq array or string
    # @return ActiveKumquat::Entity
    #
    def facet(fq)
      if fq === false
        @facet = false
      elsif fq.blank?
        # noop
      elsif fq.respond_to?(:each)
        @facet_queries += fq.reject{ |v| v.blank? }
      elsif fq.respond_to?('to_s')
        @facet_queries << fq.to_s
      end
      self
    end

    def first
      @limit = 1
      self.to_a.first
    end

    ##
    # @param limit integer
    # @return ActiveKumquat::Entity
    #
    def limit(limit)
      @limit = limit
      self
    end

    def method_missing(name, *args, &block)
      if @results.respond_to?(name)
        self.to_a.send(name, *args, &block)
      else
        super
      end
    end

    ##
    # @param order Hash or string
    # @return ActiveKumquat::ResultSet
    #
    def order(order)
      if order.kind_of?(Hash)
        order = "#{order.keys.first} #{order[order.keys.first]}"
      else
        order = order.to_s
        if !order.end_with?(' asc') and !order.end_with?(' desc')
          order += ' asc'
        end
      end
      @order = order
      self
    end

    def respond_to_missing?(method_name, include_private = false)
      @results.respond_to?(method_name) || super
    end

    ##
    # @param start integer
    # @return ActiveKumquat::Entity
    #
    def start(start)
      @start = start
      self
    end

    ##
    # @param where Hash or string
    # @return ActiveKumquat::Entity
    #
    def where(where)
      if where.blank?
        # noop
      elsif where.kind_of?(Hash)
        @where_clauses += where.reject{ |k, v| v.blank? }.
            map{ |k, v| "#{k}:#{v}" }
      elsif where.respond_to?('to_s')
        @where_clauses << where.to_s
      end
      self
    end

    def to_a
      load
      @results
    end

    private

    def load
      unless @loaded
        @where_clauses << "#{Solr::Solr::CLASS_KEY}:\"kumquat:#{@caller::ENTITY_CLASS}\"" if
            @caller.constants.include?(:ENTITY_CLASS)
        params = {
            q: @where_clauses.join(' AND '),
            df: 'kq_searchall',
            start: @start,
            sort: @order,
            rows: @limit
        }
        if @facet
          params[:facet] = true
          params['facet.mincount'] = 1
          params['facet.field'] = Solr::Solr::FACET_FIELDS
          params[:fq] = @facet_queries
        end
        solr_response = @@solr.get('select', params: params)
        @solr_request = solr_response.request
        @results.facet_fields = solr_facet_fields_to_objects(
            solr_response['facet_counts']['facet_fields']) if @facet
        solr_response['response']['docs'].each do |doc|
          entity = @caller.new(solr_json: doc, repository_url: doc['id'])

          f4_response = @@http.get(doc['id'], nil,
                                { 'Accept' => 'application/n-triples' })
          graph = RDF::Graph.new
          graph.from_ntriples(f4_response.body)
          entity.populate_from_graph(graph)
          @results << entity
        end
        @results.total_length = solr_response['response']['numFound'].to_i
        @loaded = true
      end
    end

    def solr_facet_fields_to_objects(fields)
      facets = []
      fields.each do |field, terms|
        facet = Solr::Facet.new
        facet.field = field
        (0..terms.length - 1).step(2) do |i|
          term = Solr::Facet::Term.new
          term.name = terms[i]
          term.count = terms[i + 1]
          term.facet = facet
          facet.terms << term
        end
        facets << facet
      end
      facets
    end

  end

end
