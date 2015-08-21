module Solr

  class Solr

    SCHEMA = YAML.load(File.read(File.join(__dir__, 'schema.yml')))

    @@client = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url].chomp('/') +
                                 '/' + Kumquat::Application.kumquat_config[:solr_core])

    ##
    # @return [RSolr]
    #
    def self.client
      @@client
    end

    ##
    # Gets the Solr-compatible field name for a given predicate.
    #
    # @param predicate [String]
    #
    def self.field_name_for_predicate(predicate)
      # convert all non-alphanumerics to underscores and then replace
      # repeating underscores with a single underscore
      'uri_' + predicate.to_s.gsub(/[^0-9a-z ]/i, '_').gsub(/\_+/, '_') + '_txt'
    end

    def initialize
      @http = HTTPClient.new
      @url = Kumquat::Application.kumquat_config[:solr_url].chomp('/') + '/' +
          Kumquat::Application.kumquat_config[:solr_core]
    end

    def clear
      @http.get(@url + '/update?stream.body=<delete><query>*:*</query></delete>')
      @http.get(@url + '/update?stream.body=<commit/>')
    end

    ##
    # @param term [String] Search term
    # @return [Array] String suggestions
    #
    def suggestions(term)
      result = Solr::client.get('suggest', params: { q: term })
      suggestions = result['spellcheck']['suggestions']
      suggestions.any? ? suggestions[1]['suggestion'] : []
    end

    ##
    # Creates the set of fields needed by the application. This requires
    # Solr 5.2+ with the ManagedIndexSchemaFactory enabled and a mutable schema.
    #
    def update_schema
      response = @http.get("#{@url}/schema")
      current = JSON.parse(response.body)

      # delete obsolete dynamic fields
      dynamic_fields_to_delete = current['schema']['dynamicFields'].select do |cf|
        !SCHEMA['dynamicFields'].map{ |sf| sf['name'] }.include?(cf['name'])
      end
      dynamic_fields_to_delete.each do |df|
        post_fields('delete-dynamic-field', { 'name' => df['name'] })
      end

      # add new dynamic fields
      dynamic_fields_to_add = SCHEMA['dynamicFields'].reject do |kf|
        current['schema']['dynamicFields'].
            map{ |sf| sf['name'] }.include?(kf['name'])
      end
      post_fields('add-dynamic-field', dynamic_fields_to_add)

      # copy faceted triples into facet fields
      facetable_fields = Triple.where('facet_id IS NOT NULL').
          uniq(&:predicate).map do |t|
        { source: self.class.field_name_for_predicate(t.predicate),
          dest: t.facet.solr_field }
      end
      facetable_fields << {
          source: Fields::COLLECTION,
          dest: Facet.where(name: 'Collection').first.solr_field }
      facetable_fields_to_add = facetable_fields.reject do |ff|
        current['schema']['copyFields'].
            map{ |sf| "#{sf['source']}-#{sf['dest']}" }.
            include?("#{ff['source']}-#{ff['dest']}")
      end
      post_fields('add-copy-field', facetable_fields_to_add)

      # copy various fields into a search-all field
      search_all_fields_to_add = search_all_fields.reject do |ff|
        current['schema']['copyFields'].
            map{ |sf| "#{sf['source']}-#{sf['dest']}" }.
            include?("#{ff['source']}-#{ff['dest']}")
      end
      post_fields('add-copy-field', search_all_fields_to_add)

      # delete obsolete copyFields
      copy_fields_to_delete = current['schema']['copyFields'].select do |kf|
        !SCHEMA['copyFields'].map{ |sf| "#{sf['source']}#{sf['dest']}" }.
            include?("#{kf['source']}#{kf['dest']}")
      end
      post_fields('delete-copy-field', copy_fields_to_delete)

      # add new copyFields
      copy_fields_to_add = SCHEMA['copyFields'].reject do |kf|
        current['schema']['copyFields'].
            map{ |sf| "#{sf['source']}#{sf['dest']}" }.
            include?("#{kf['source']}#{kf['dest']}")
      end
      post_fields('add-copy-field', copy_fields_to_add)
    end

    private

    ##
    # @param key [String]
    # @param fields [Array]
    #
    def post_fields(key, fields)
      if fields.any?
        json = JSON.generate({ key => fields })
        response = @http.post("#{@url}/schema", json,
                             { 'Content-Type' => 'application/json' })
        message = JSON.parse(response.body)
        if message['errors']
          raise "Failed to update Solr schema: #{message['errors']}"
        end
      end
    end

    ##
    # Returns a list of fields that will be copied into a "search-all" field
    # for easy searching.
    #
    # @return [Array] Array of strings
    #
    def search_all_fields
      dest = 'kq_searchall_txt'
      fields = Triple.all.uniq(&:predicate).map do |t|
        { source: self.class.field_name_for_predicate(t.predicate),
          dest: dest }
      end
      fields << { source: 'kq_sys_full_text_txt', dest: dest }
      fields
    end

  end

end
