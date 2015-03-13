module ActiveKumquat

  ##
  # Bare-bones class that assists in building SPARQL Update statements.
  #
  # TODO: replace with ruby-rdf/sparql when it supports SPARQL update
  #
  class SparqlUpdate

    def initialize
      @deletes = []
      @inserts = []
      @prefixes = Set.new
    end

    ##
    # Adds a statement into a DELETE WHERE clause.
    #
    # @param subject string nil will result in "<>"
    # @param predicate string
    # @param object string
    # @param quote_object boolean
    # @return self
    #
    def delete(subject, predicate, object, quote_object = true)
      object = quote_object ? "\"#{object.to_s.gsub('"', '\"')}\"" : object
      @deletes << { subject: subject, predicate: predicate, object: object }
      self
    end

    ##
    # Adds a statement into an INSERT clause.
    #
    # @param subject string nil will result in "<>"
    # @param predicate string
    # @param object string
    # @param quote_object boolean
    # @return self
    #
    def insert(subject, predicate, object, quote_object = true)
      object = quote_object ? "\"#{object.to_s.gsub('"', '\"')}\"" : object
      @inserts << { subject: subject, predicate: predicate, object: object }
      self
    end

    ##
    # @param prefix string
    # @param uri string
    # @return self
    #
    def prefix(prefix, uri)
      @prefixes << { prefix: prefix, uri: uri } unless prefix.blank? or
          uri.blank?
      self
    end

    def to_s
      s = ''
      @prefixes.each do |hash|
        s += "PREFIX #{hash[:prefix]}: <#{hash[:uri]}>\n"
      end

      @deletes.uniq.each do |i|
        subject = i[:subject].nil? ? '<>' : i[:subject]
        s += "DELETE WHERE { #{subject} #{i[:predicate]} #{i[:object]} };\n"
      end

      s += "INSERT {\n"
      inserts = @inserts.uniq.map do |i|
        subject = i[:subject].nil? ? '<>' : i[:subject]
        "  #{subject} #{i[:predicate]} #{i[:object]}"
      end
      s += inserts.join(" .\n")
      s += " .\n}\nWHERE { }"
    end

  end

end
