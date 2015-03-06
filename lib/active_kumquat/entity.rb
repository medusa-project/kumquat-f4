module ActiveKumquat

  ##
  # Query builder class, conceptually similar to ActiveRecord::Relation.
  #
  class Entity

    @@http = HTTPClient.new
    @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

    def initialize(caller)
      @caller = caller
      @limit = nil
      @loaded = false
      @order = nil
      @results = ResultSet.new
      @start = 0
      @where_conditions = [] # will be joined by AND
    end

    def count
      @start = 0
      @limit = 0
      self.to_a.total_length
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
        @where_conditions += where.reject{ |k, v| v.blank? }.
            map{ |k, v| "#{k}:#{v}" }
      elsif where.respond_to?('to_s')
        @where_conditions << where.to_s
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
        @where_conditions << "kq_resource_type:#{@caller::ENTITY_TYPE}" if
            @caller.constants.include?(:ENTITY_TYPE)
        solr_response = @@solr.get('select',
                                   params: {
                                       q: @where_conditions.join(' AND '),
                                       df: 'dc_title',
                                       start: @start,
                                       sort: @order,
                                       rows: @limit })
        solr_response['response']['docs'].each do |doc|
          entity = @caller.new(solr_representation: doc, fedora_url: doc['id'])

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

  end

end
