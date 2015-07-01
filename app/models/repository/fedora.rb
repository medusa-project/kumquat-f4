module Repository

  class Fedora

    INDEXING_TRANSFORM_NAME = 'kumquat'

    # Predicate URIs that start with any of these are repository-managed.
    MANAGED_PREDICATES = [
        'http://fedora.info/definitions/',
        'http://www.jcp.org/jcr',
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        'http://www.w3.org/2000/01/rdf-schema#',
        'http://www.w3.org/ns/ldp#'
    ]

    ##
    # Creates or updates the Fedora indexing transform used by the application.
    #
    # https://wiki.duraspace.org/display/FEDORA41/Indexing+Transformations
    # http://wiki.apache.org/marmotta/LDPath
    #
    def apply_indexing_transform
      http = HTTPClient.new
      url = "#{Kumquat::Application.kumquat_config[:fedora_url].chomp('/')}"\
      "/fedora:system/fedora:transform/fedora:ldpath/#{INDEXING_TRANSFORM_NAME}/fedora:Container"
      http.put(url, indexing_transform,
               { 'Content-Type' => 'application/rdf+ldpath' })
    end

    ##
    # @return [String] The Fedora indexing transform to be used by the
    # application.
    #
    def indexing_transform
      kq_predicates = Kumquat::RDFPredicates
      "@prefix fcrepo : <http://fedora.info/definitions/v4/repository#>
      @prefix dc : <http://purl.org/dc/elements/1.1/>
      @prefix dcterms : <http://purl.org/dc/terms/>
      @prefix kumquat : <#{Kumquat::NAMESPACE_URI}>

      id = . :: xsd:string;
      #{Solr::Fields::UUID} = fcrepo:uuid :: xsd:string;
      #{Solr::Fields::CLASS} = <#{ActiveMedusa::Configuration.instance.class_predicate}> :: xsd:anyURI;
      #{Solr::Fields::COLLECTION} = kumquat:#{kq_predicates::IS_MEMBER_OF_COLLECTION} :: xsd:anyURI;
      #{Solr::Fields::COLLECTION_KEY} = kumquat:#{kq_predicates::COLLECTION_KEY} :: xsd:string;
      #{Solr::Fields::CREATED_AT} = fcrepo:created :: xsd:string;
      #{Solr::Fields::DATE} = kumquat:#{kq_predicates::DATE} :: xsd:dateTime;
      #{Solr::Fields::FULL_TEXT} = kumquat:#{kq_predicates::FULL_TEXT} :: xsd:string;
      #{Solr::Fields::HEIGHT} = kumquat:#{kq_predicates::HEIGHT} :: xsd:integer;
      #{Solr::Fields::ITEM} = kumquat:#{kq_predicates::IS_MEMBER_OF_ITEM} :: xsd:anyURI;
      #{Solr::Fields::PAGE_INDEX} = kumquat:#{kq_predicates::PAGE_INDEX} :: xsd:integer;
      #{Solr::Fields::PARENT_URI} = kumquat:#{kq_predicates::PARENT_URI} :: xsd:anyURI;
      #{Solr::Fields::PUBLISHED} = kumquat:#{kq_predicates::PUBLISHED} :: xsd:boolean;
      #{Solr::Fields::UPDATED_AT} = fcrepo:lastModified :: xsd:string;
      #{Solr::Fields::SINGLE_TITLE} = fn:concat(dc:title,\"\",dcterms:title) :: xsd:string;
      #{Solr::Fields::WEB_ID} = kumquat:#{kq_predicates::WEB_ID} :: xsd:string;
      #{Solr::Fields::WIDTH} = kumquat:#{kq_predicates::WIDTH} :: xsd:integer;
      uri_http_purl_org_dc_elements_1_1_contributor_txt = dc:contributor :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_coverage_txt = dc:coverage :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_creator_txt = dc:creator :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_date_txt = dc:date :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_description_txt = dc:description :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_format_txt = dc:format :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_identifier_s = dc:identifier :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_language_txt = dc:language :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_publisher_txt = dc:publisher :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_relation_txt = dc:relation :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_rights_txt = dc:rights :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_source_txt = dc:source :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_subject_txt = dc:subject :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_title_txt = dc:title :: xsd:string;
      uri_http_purl_org_dc_elements_1_1_type_txt = dc:type :: xsd:string;
      uri_http_purl_org_dc_terms_abstract_txt = dcterms:abstract :: xsd:string;
      uri_http_purl_org_dc_terms_accessRights_txt = dcterms:accessRights :: xsd:string;
      uri_http_purl_org_dc_terms_accrualMethod_txt = dcterms:accrualMethod :: xsd:string;
      uri_http_purl_org_dc_terms_accrualPeriodicity_txt = dcterms:accrualPeriodicity :: xsd:string;
      uri_http_purl_org_dc_terms_accrualPolicy_txt = dcterms:accrualPolicy :: xsd:string;
      uri_http_purl_org_dc_terms_alternative_txt = dcterms:alternative :: xsd:string;
      uri_http_purl_org_dc_terms_audience_txt = dcterms:audience :: xsd:string;
      uri_http_purl_org_dc_terms_available_txt = dcterms:available :: xsd:string;
      uri_http_purl_org_dc_terms_bibliographicCitation_txt = dcterms:bibliographicCitation :: xsd:string;
      uri_http_purl_org_dc_terms_conformsTo_txt = dcterms:conformsTo :: xsd:string;
      uri_http_purl_org_dc_terms_contributor_txt = dcterms:contributor :: xsd:string;
      uri_http_purl_org_dc_terms_coverage_txt = dcterms:coverage :: xsd:string;
      uri_http_purl_org_dc_terms_created_txt = dcterms:created :: xsd:string;
      uri_http_purl_org_dc_terms_creator_txt = dcterms:creator :: xsd:string;
      uri_http_purl_org_dc_terms_date_txt = dcterms:date :: xsd:string;
      uri_http_purl_org_dc_terms_dateAccepted_txt = dcterms:dateAccepted :: xsd:string;
      uri_http_purl_org_dc_terms_dateCopyrighted_txt = dcterms:dateCopyrighted :: xsd:string;
      uri_http_purl_org_dc_terms_dateSubmitted_txt = dcterms:dateSubmitted :: xsd:string;
      uri_http_purl_org_dc_terms_description_txt = dcterms:description :: xsd:string;
      uri_http_purl_org_dc_terms_educationLevel_txt = dcterms:educationLevel :: xsd:string;
      uri_http_purl_org_dc_terms_extent_txt = dcterms:extent :: xsd:string;
      uri_http_purl_org_dc_terms_format_txt = dcterms:format :: xsd:string;
      uri_http_purl_org_dc_terms_hasFormat_txt = dcterms:hasFormat :: xsd:string;
      uri_http_purl_org_dc_terms_hasPart_txt = dcterms:hasPart :: xsd:string;
      uri_http_purl_org_dc_terms_hasVersion_txt = dcterms:hasVersion :: xsd:string;
      uri_http_purl_org_dc_terms_identifier_s = dcterms:identifier :: xsd:string;
      uri_http_purl_org_dc_terms_instructionalMethod_txt = dcterms:instructionalMethod :: xsd:string;
      uri_http_purl_org_dc_terms_isFormatOf_txt = dcterms:isFormatOf :: xsd:string;
      uri_http_purl_org_dc_terms_isPartOf_txt = dcterms:isPartOf :: xsd:string;
      uri_http_purl_org_dc_terms_isReferencedBy_txt = dcterms:isReferencedBy :: xsd:string;
      uri_http_purl_org_dc_terms_isReplacedBy_txt = dcterms:isReplacedBy :: xsd:string;
      uri_http_purl_org_dc_terms_isRequiredBy_txt = dcterms:isRequiredBy :: xsd:string;
      uri_http_purl_org_dc_terms_issued_txt = dcterms:issued :: xsd:string;
      uri_http_purl_org_dc_terms_isVersionOf_txt = dcterms:isVersionOf :: xsd:string;
      uri_http_purl_org_dc_terms_language_txt = dcterms:language :: xsd:string;
      uri_http_purl_org_dc_terms_license_txt = dcterms:license :: xsd:string;
      uri_http_purl_org_dc_terms_mediator_txt = dcterms:mediator :: xsd:string;
      uri_http_purl_org_dc_terms_MediaType_txt = dcterms:MediaType :: xsd:string;
      uri_http_purl_org_dc_terms_medium_txt = dcterms:medium :: xsd:string;
      uri_http_purl_org_dc_terms_modified_txt = dcterms:modified :: xsd:string;
      uri_http_purl_org_dc_terms_provenance_txt = dcterms:provenance :: xsd:string;
      uri_http_purl_org_dc_terms_publisher_txt = dcterms:publisher :: xsd:string;
      uri_http_purl_org_dc_terms_references_txt = dcterms:references :: xsd:string;
      uri_http_purl_org_dc_terms_relation_txt = dcterms:relation :: xsd:string;
      uri_http_purl_org_dc_terms_replaces_txt = dcterms:replaces :: xsd:string;
      uri_http_purl_org_dc_terms_requires_txt = dcterms:requires :: xsd:string;
      uri_http_purl_org_dc_terms_rights_txt = dcterms:rights :: xsd:string;
      uri_http_purl_org_dc_terms_rightsHolder_txt = dcterms:rightsHolder :: xsd:string;
      uri_http_purl_org_dc_terms_source_txt = dcterms:source :: xsd:string;
      uri_http_purl_org_dc_terms_spatial_txt = dcterms:spatial :: xsd:string;
      uri_http_purl_org_dc_terms_subject_txt = dcterms:subject :: xsd:string;
      uri_http_purl_org_dc_terms_tableOfContents_txt = dcterms:tableOfContents :: xsd:string;
      uri_http_purl_org_dc_terms_temporal_txt = dcterms:temporal :: xsd:string;
      uri_http_purl_org_dc_terms_title_txt = dcterms:title :: xsd:string;
      uri_http_purl_org_dc_terms_type_txt = dcterms:type :: xsd:string;
      uri_http_purl_org_dc_terms_valid_txt = dcterms:valid :: xsd:string;"
    end

  end

end
