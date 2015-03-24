module Contentdm

  ##
  # Encapsulates an "unmapped" element.
  #
  class LocalElement < Element

    def namespace_prefix
      'uiuc' # TODO: externalize
    end

    def uri
      name = self.name || 'unmapped'
      "http://imagesearch.library.illinois.edu/#{name}" # TODO: externalize
    end

  end

end
