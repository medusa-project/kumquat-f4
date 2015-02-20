class Triple

  # the subject is implicitly the owning object, e.g. an Item
  attr_accessor :object
  attr_accessor :predicate
  attr_accessor :type

  alias_method :value, :object
  alias_method :name, :predicate

  LABELS = {
      'http://purl.org/dc/elements/1.1/contributor' => 'Contributor',
      'http://purl.org/dc/elements/1.1/coverage' => 'Coverage',
      'http://purl.org/dc/elements/1.1/creator' => 'Creator',
      'http://purl.org/dc/elements/1.1/date' => 'Date',
      'http://purl.org/dc/elements/1.1/description' => 'Description',
      'http://purl.org/dc/elements/1.1/format' => 'Format',
      'http://purl.org/dc/elements/1.1/identifier' => 'Identifier',
      'http://purl.org/dc/elements/1.1/language' => 'Language',
      'http://purl.org/dc/elements/1.1/publisher' => 'Publisher',
      'http://purl.org/dc/elements/1.1/relation' => 'Relation',
      'http://purl.org/dc/elements/1.1/rights' => 'Rights',
      'http://purl.org/dc/elements/1.1/source' => 'Source',
      'http://purl.org/dc/elements/1.1/subject' => 'Subject',
      'http://purl.org/dc/elements/1.1/title' => 'Title',
      'http://purl.org/dc/elements/1.1/type' => 'Type',
      'http://purl.org/dc/terms/abstract' => 'Abstract',
      'http://purl.org/dc/terms/accessRights' => 'Access Rights',
      'http://purl.org/dc/terms/accrualMethod' => 'Accrual Method',
      'http://purl.org/dc/terms/accrualPeriodicity' => 'Accrual Periodicity',
      'http://purl.org/dc/terms/accrualPolicy' => 'Accrual Policy',
      'http://purl.org/dc/terms/alternative' => 'Alternative Title',
      'http://purl.org/dc/terms/audience' => 'Audience',
      'http://purl.org/dc/terms/available' => 'Date Available',
      'http://purl.org/dc/terms/bibliographicCitation' => 'Bibliographic Citation',
      'http://purl.org/dc/terms/conformsTo' => 'Conforms To',
      'http://purl.org/dc/terms/contributor' => 'Contributor',
      'http://purl.org/dc/terms/coverage' => 'Coverage',
      'http://purl.org/dc/terms/created' => 'Created',
      'http://purl.org/dc/terms/creator' => 'Creator',
      'http://purl.org/dc/terms/date' => 'Date',
      'http://purl.org/dc/terms/dateAccepted' => 'Date Accepted',
      'http://purl.org/dc/terms/dateCopyrighted' => 'Date Copyrighted',
      'http://purl.org/dc/terms/dateSubmitted' => 'Date Submitted',
      'http://purl.org/dc/terms/description' => 'Description',
      'http://purl.org/dc/terms/educationLevel' => 'Audience Education Level',
      'http://purl.org/dc/terms/extent' => 'Extent',
      'http://purl.org/dc/terms/format' => 'Format',
      'http://purl.org/dc/terms/hasFormat' => 'Has Format',
      'http://purl.org/dc/terms/hasPart' => 'Has Part',
      'http://purl.org/dc/terms/hasVersion' => 'Has Version',
      'http://purl.org/dc/terms/identifier' => 'Identifier',
      'http://purl.org/dc/terms/instructionalMethod' => 'Instructional Method',
      'http://purl.org/dc/terms/isFormatOf' => 'Is Format Of',
      'http://purl.org/dc/terms/isPartOf' => 'Is Part Of',
      'http://purl.org/dc/terms/isReferencedBy' => 'Is Referenced By',
      'http://purl.org/dc/terms/isReplacedBy' => 'Is Replaced By',
      'http://purl.org/dc/terms/isRequiredBy' => 'Is Required By',
      'http://purl.org/dc/terms/issued' => 'Issued',
      'http://purl.org/dc/terms/isVersionOf' => 'Is Version Of',
      'http://purl.org/dc/terms/language' => 'Language',
      'http://purl.org/dc/terms/license' => 'License',
      'http://purl.org/dc/terms/mediator' => 'Mediator',
      'http://purl.org/dc/terms/medium' => 'Medium',
      'http://purl.org/dc/terms/modified' => 'Date Modified',
      'http://purl.org/dc/terms/provenance' => 'Provenance',
      'http://purl.org/dc/terms/publisher' => 'Publisher',
      'http://purl.org/dc/terms/references' => 'References',
      'http://purl.org/dc/terms/relation' => 'Relation',
      'http://purl.org/dc/terms/replaces' => 'Replaces',
      'http://purl.org/dc/terms/requires' => 'Requires',
      'http://purl.org/dc/terms/rights' => 'Rights',
      'http://purl.org/dc/terms/rightsHolder' => 'Rights Holder',
      'http://purl.org/dc/terms/source' => 'Source',
      'http://purl.org/dc/terms/spatial' => 'Spatial',
      'http://purl.org/dc/terms/subject' => 'Subject',
      'http://purl.org/dc/terms/tableOfContents' => 'Table Of Contents',
      'http://purl.org/dc/terms/temporal' => 'Temporal Coverage',
      'http://purl.org/dc/terms/title' => 'Title',
      'http://purl.org/dc/terms/type' => 'Type',
      'http://purl.org/dc/terms/valid' => 'Date Valid'
  }

  def initialize(params = {})
    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def label
    LABELS[self.predicate] ? LABELS[self.predicate] : ''
  end

end
