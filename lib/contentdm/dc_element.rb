module Contentdm

  class DCElement < Element

    URIS = [
        'http://purl.org/dc/terms/abstract',
        'http://purl.org/dc/terms/accessRights',
        'http://purl.org/dc/terms/accrualMethod',
        'http://purl.org/dc/terms/accrualPeriodicity',
        'http://purl.org/dc/terms/accrualPolicy',
        'http://purl.org/dc/terms/alternative',
        'http://purl.org/dc/terms/audience',
        'http://purl.org/dc/terms/available',
        'http://purl.org/dc/terms/bibliographicCitation',
        'http://purl.org/dc/terms/conformsTo',
        'http://purl.org/dc/terms/contributor',
        'http://purl.org/dc/terms/coverage',
        'http://purl.org/dc/terms/created',
        'http://purl.org/dc/terms/creator',
        'http://purl.org/dc/terms/date',
        'http://purl.org/dc/terms/dateAccepted',
        'http://purl.org/dc/terms/dateCopyrighted',
        'http://purl.org/dc/terms/dateSubmitted',
        'http://purl.org/dc/terms/description',
        'http://purl.org/dc/terms/educationLevel',
        'http://purl.org/dc/terms/extent',
        'http://purl.org/dc/terms/format',
        'http://purl.org/dc/terms/hasFormat',
        'http://purl.org/dc/terms/hasPart',
        'http://purl.org/dc/terms/hasVersion',
        'http://purl.org/dc/terms/identifier',
        'http://purl.org/dc/terms/instructionalMethod',
        'http://purl.org/dc/terms/isFormatOf',
        'http://purl.org/dc/terms/isPartOf',
        'http://purl.org/dc/terms/isReferencedBy',
        'http://purl.org/dc/terms/isReplacedBy',
        'http://purl.org/dc/terms/isRequiredBy',
        'http://purl.org/dc/terms/issued',
        'http://purl.org/dc/terms/isVersionOf',
        'http://purl.org/dc/terms/language',
        'http://purl.org/dc/terms/license',
        'http://purl.org/dc/terms/mediator',
        'http://purl.org/dc/terms/medium',
        'http://purl.org/dc/terms/modified',
        'http://purl.org/dc/terms/provenance',
        'http://purl.org/dc/terms/publisher',
        'http://purl.org/dc/terms/references',
        'http://purl.org/dc/terms/relation',
        'http://purl.org/dc/terms/replaces',
        'http://purl.org/dc/terms/requires',
        'http://purl.org/dc/terms/rights',
        'http://purl.org/dc/terms/rightsHolder',
        'http://purl.org/dc/terms/source',
        'http://purl.org/dc/terms/spatial',
        'http://purl.org/dc/terms/subject',
        'http://purl.org/dc/terms/tableOfContents',
        'http://purl.org/dc/terms/temporal',
        'http://purl.org/dc/terms/title',
        'http://purl.org/dc/terms/type',
        'http://purl.org/dc/terms/valid'
    ]

    def namespace_prefix
      'dcterms'
    end

    def uri
      parts = URIS.select{ |u| u.include?(self.name) }.first.split('/')
      parts[0..(parts.length - 2)].join('/') + '/' + self.name
    end

  end

end
