module Contentdm

  ##
  # Encapsulates an "unmapped" element.
  #
  class LocalElement < Element

    def namespace_prefix
      'uiuc' # TODO: externalize
    end

    def namespace_uri
      'http://imagesearch.library.illinois.edu/' # TODO: externalize
    end

  end

end
