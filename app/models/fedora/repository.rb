module Fedora

  class Repository

    INDEXING_TRANSFORM_NAME = 'kumquat'

    class LocalTriples
      COLLECTION_KEY = 'collectionKey'
      HEIGHT = 'height'
      MASTER_BYTESTREAM_URI = 'hasMasterBytestream'
      PAGE_INDEX = 'pageIndex'
      PARENT_UUID = 'parentUUID'
      RESOURCE_TYPE = 'resourceType'
      WEB_ID = 'webID'
      WIDTH = 'width'
    end

    ##
    # Creates or updates the Fedora indexing transform used by the application.
    #
    # https://wiki.duraspace.org/display/FEDORA41/Indexing+Transformations
    #
    def apply_indexing_transform
      body = "@prefix fcrepo : <http://fedora.info/definitions/v4/repository#>
      @prefix dc : <http://purl.org/dc/elements/1.1/>
      @prefix dcterms : <http://purl.org/dc/terms/>
      @prefix kumquat : <#{Kumquat::Application::NAMESPACE_URI}>

      id = . :: xsd:string;
      uuid = fcrepo:uuid :: xsd:string;
      #{Solr::Solr::COLLECTION_KEY_KEY} = kumquat:#{LocalTriples::COLLECTION_KEY} :: xsd:string;
      #{Solr::Solr::MASTER_BYTESTREAM_URI_KEY} = kumquat:#{LocalTriples::MASTER_BYTESTREAM_URI} :: xsd:string;
      #{Solr::Solr::HEIGHT_KEY} = kumquat:#{LocalTriples::HEIGHT} :: xsd:integer;
      #{Solr::Solr::MEDIA_TYPE_KEY} = dcterms:MediaType :: xsd:string;
      #{Solr::Solr::PAGE_INDEX_KEY} = kumquat:#{LocalTriples::PAGE_INDEX} :: xsd:integer;
      #{Solr::Solr::PARENT_UUID_KEY} = kumquat:#{LocalTriples::PARENT_UUID} :: xsd:string;
      #{Solr::Solr::RESOURCE_TYPE_KEY} = kumquat:#{LocalTriples::RESOURCE_TYPE} :: xsd:string;
      #{Solr::Solr::WEB_ID_KEY} = kumquat:#{LocalTriples::WEB_ID} :: xsd:string;
      #{Solr::Solr::WIDTH_KEY} = kumquat:#{LocalTriples::WIDTH} :: xsd:integer;
      dc_contributor = dc:contributor :: xsd:string;
      dc_coverage = dc:coverage :: xsd:string;
      dc_creator = dc:creator :: xsd:string;
      dc_date = dc:date :: xsd:string;
      dc_description = dc:description :: xsd:string;
      dc_format = dc:format :: xsd:string;
      dc_identifier = dc:identifier :: xsd:string;
      dc_language = dc:language :: xsd:string;
      dc_publisher = dc:publisher :: xsd:string;
      dc_relation = dc:relation :: xsd:string;
      dc_rights = dc:rights :: xsd:string;
      dc_source = dc:source :: xsd:string;
      dc_subject = dc:subject :: xsd:string;
      dc_title = dc:title :: xsd:string;
      dc_type = dc:type :: xsd:string;
      dcterm_abstract = dcterms:abstract :: xsd:string;
      dcterm_accessRights = dcterms:accessRights :: xsd:string;
      dcterm_accrualMethod = dcterms:accrualMethod :: xsd:string;
      dcterm_accrualPeriodicity = dcterms:accrualPeriodicity :: xsd:string;
      dcterm_accrualPolicy = dcterms:accrualPolicy :: xsd:string;
      dcterm_alternative = dcterms:alternative :: xsd:string;
      dcterm_audience = dcterms:audience :: xsd:string;
      dcterm_available = dcterms:available :: xsd:string;
      dcterm_bibliographicCitation = dcterms:bibliographicCitation :: xsd:string;
      dcterm_conformsTo = dcterms:conformsTo :: xsd:string;
      dcterm_contributor = dcterms:contributor :: xsd:string;
      dcterm_coverage = dcterms:coverage :: xsd:string;
      dcterm_created = dcterms:created :: xsd:string;
      dcterm_creator = dcterms:creator :: xsd:string;
      dcterm_date = dcterms:date :: xsd:string;
      dcterm_dateAccepted = dcterms:dateAccepted :: xsd:string;
      dcterm_dateCopyrighted = dcterms:dateCopyrighted :: xsd:string;
      dcterm_dateSubmitted = dcterms:dateSubmitted :: xsd:string;
      dcterm_description = dcterms:description :: xsd:string;
      dcterm_educationLevel = dcterms:educationLevel :: xsd:string;
      dcterm_extent = dcterms:extent :: xsd:string;
      dcterm_format = dcterms:format :: xsd:string;
      dcterm_hasFormat = dcterms:hasFormat :: xsd:string;
      dcterm_hasPart = dcterms:hasPart :: xsd:string;
      dcterm_hasVersion = dcterms:hasVersion :: xsd:string;
      dcterm_identifier = dcterms:identifier :: xsd:string;
      dcterm_instructionalMethod = dcterms:instructionalMethod :: xsd:string;
      dcterm_isFormatOf = dcterms:isFormatOf :: xsd:string;
      dcterm_isPartOf = dcterms:isPartOf :: xsd:string;
      dcterm_isReferencedBy = dcterms:isReferencedBy :: xsd:string;
      dcterm_isReplacedBy = dcterms:isReplacedBy :: xsd:string;
      dcterm_isRequiredBy = dcterms:isRequiredBy :: xsd:string;
      dcterm_issued = dcterms:issued :: xsd:string;
      dcterm_isVersionOf = dcterms:isVersionOf :: xsd:string;
      dcterm_language = dcterms:language :: xsd:string;
      dcterm_license = dcterms:license :: xsd:string;
      dcterm_mediator = dcterms:mediator :: xsd:string;
      dcterm_medium = dcterms:medium :: xsd:string;
      dcterm_modified = dcterms:modified :: xsd:string;
      dcterm_provenance = dcterms:provenance :: xsd:string;
      dcterm_publisher = dcterms:publisher :: xsd:string;
      dcterm_references = dcterms:references :: xsd:string;
      dcterm_relation = dcterms:relation :: xsd:string;
      dcterm_replaces = dcterms:replaces :: xsd:string;
      dcterm_requires = dcterms:requires :: xsd:string;
      dcterm_rights = dcterms:rights :: xsd:string;
      dcterm_rightsHolder = dcterms:rightsHolder :: xsd:string;
      dcterm_source = dcterms:source :: xsd:string;
      dcterm_spatial = dcterms:spatial :: xsd:string;
      dcterm_subject = dcterms:subject :: xsd:string;
      dcterm_tableOfContents = dcterms:tableOfContents :: xsd:string;
      dcterm_temporal = dcterms:temporal :: xsd:string;
      dcterm_title = dcterms:title :: xsd:string;
      dcterm_type = dcterms:type :: xsd:string;
      dcterm_valid = dcterms:valid :: xsd:string;"
      http = HTTPClient.new
      url = "#{Kumquat::Application.kumquat_config[:fedora_url].chomp('/')}"\
      "/fedora:system/fedora:transform/fedora:ldpath/#{INDEXING_TRANSFORM_NAME}/fedora:Container"
      http.put(url, body, { 'Content-Type' => 'application/rdf+ldpath' })
    end

  end

end
