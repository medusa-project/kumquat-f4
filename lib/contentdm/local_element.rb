module Contentdm

  ##
  # Encapsulates an "unmapped" element.
  #
  class LocalElement < Element

    def namespace_prefix
      'uiuc' # TODO: externalize
    end

    def uri
      "http://imagesearch.library.illinois.edu/#{self.name}" # TODO: externalize
    end

  end

end
