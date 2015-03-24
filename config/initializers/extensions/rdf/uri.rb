module RDF

  ##
  # Reopen RDF::URI to add some useful methods.
  #
  class URI

    def prefix
      prefix_model = DB::URIPrefix.all.where(uri: self.prefixable).limit(1)
      prefix_model.any? ? prefix_model.first.prefix : nil
    end

    def prefixable
      glue = self.to_s.include?('#') ? '#' : '/'
      parts = self.to_s.split(glue)
      parts.pop
      parts.join(glue) + glue
    end

    def term
      glue = self.to_s.include?('#') ? '#' : '/'
      parts = self.to_s.split(glue)
      parts.pop
    end

  end

end
