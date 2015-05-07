module Solr

  class Solr

    ##
    # Schema summary:
    #
    # uri_*_txt          arbitrary RDF objects
    # kq_meta_*          normalized metadata schema into which many of the
    #                    uri_* fields are copied (notably, /dc/elements/1.1 and
    #                    /dc/terms are merged)
    # kq_meta_title_s    Single-valued title field that can be sorted (must be
    #                    populated manually)
    # kq_meta_date_dts   Single-valued date field
    # kq_sys_*           system properties
    # kq_*_facet         facets
    # kq_searchall_txt   full-text search field
    #
    # There are no classic fields, only dynamicFields and copyFields.
    #
    # The values of this hash will be POSTed as-is to Solr's schema API
    # endpoint.
    #
    SCHEMA = {
        copyFields: [
            # Map various fields to Kumquat's own schema. The main purpose
            # of this is to normalize the DC elements and terms.
            {
                source: 'uri_http_purl_org_dc_elements_1_1_contributor_txt',
                dest: 'kq_meta_contributor_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_coverage_txt',
                dest: 'kq_meta_coverage_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_creator_txt',
                dest: 'kq_meta_creator_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_date_txt',
                dest: 'kq_meta_date_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_description_txt',
                dest: 'kq_meta_description_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_format_txt',
                dest: 'kq_meta_format_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_identifier_s',
                dest: 'kq_meta_identifier_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_language_txt',
                dest: 'kq_meta_language_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_publisher_txt',
                dest: 'kq_meta_publisher_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_relation_txt',
                dest: 'kq_meta_relation_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_rights_txt',
                dest: 'kq_meta_rights_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_source_txt',
                dest: 'kq_meta_source_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_subject_txt',
                dest: 'kq_meta_subject_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_title_txt',
                dest: 'kq_meta_title_txt'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_type_txt',
                dest: 'kq_meta_type_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_abstract_txt',
                dest: 'kq_meta_abstract_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_accessRights_txt',
                dest: 'kq_meta_accessRights_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_accrualMethod_txt',
                dest: 'kq_meta_accrualMethod_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_accrualPeriodicity_txt',
                dest: 'kq_meta_accrualPeriodicity_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_accrualPolicy_txt',
                dest: 'kq_meta_accrualPolicy_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_alternative_txt',
                dest: 'kq_meta_alternative_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_audience_txt',
                dest: 'kq_meta_audience_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_available_txt',
                dest: 'kq_meta_available_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_bibliographicCitation_txt',
                dest: 'kq_meta_bibliographicCitation_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_conformsTo_txt',
                dest: 'kq_meta_conformsTo_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_contributor_txt',
                dest: 'kq_meta_contributor_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_coverage_txt',
                dest: 'kq_meta_coverage_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_created_txt',
                dest: 'kq_meta_created_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_creator_txt',
                dest: 'kq_meta_creator_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_date_txt',
                dest: 'kq_meta_date_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_dateAccepted_txt',
                dest: 'kq_meta_dateAccepted_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_dateCopyrighted_txt',
                dest: 'kq_meta_dateCopyrighted_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_dateSubmitted_txt',
                dest: 'kq_meta_dateSubmitted_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_description_txt',
                dest: 'kq_meta_description_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_educationLevel_txt',
                dest: 'kq_meta_educationLevel_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_extent_txt',
                dest: 'kq_meta_extent_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_format_txt',
                dest: 'kq_meta_format_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_hasFormat_txt',
                dest: 'kq_meta_hasFormat_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_hasPart_txt',
                dest: 'kq_meta_hasPart_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_hasVersion_txt',
                dest: 'kq_meta_hasVersion_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_identifier_txt',
                dest: 'kq_meta_identifier_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_instructionalMethod_txt',
                dest: 'kq_meta_instructionalMethod_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isFormatOf_txt',
                dest: 'kq_meta_isFormatOf_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isPartOf_txt',
                dest: 'kq_meta_isPartOf_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isReferencedBy_txt',
                dest: 'kq_meta_isReferencedBy_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isReplacedBy_txt',
                dest: 'kq_meta_isReplacedBy_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isRequiredBy_txt',
                dest: 'kq_meta_isRequiredBy_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_issued_txt',
                dest: 'kq_meta_issued_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_isVersionOf_txt',
                dest: 'kq_meta_language_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_language_txt',
                dest: 'kq_meta_language_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_license_txt',
                dest: 'kq_meta_license_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_mediator_txt',
                dest: 'kq_meta_mediator_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_MediaType_txt',
                dest: 'kq_sys_media_type_s'
            },
            {
                source: 'uri_http_purl_org_dc_terms_medium_txt',
                dest: 'kq_meta_medium_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_modified_txt',
                dest: 'kq_meta_modified_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_provenance_txt',
                dest: 'kq_meta_provenance_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_publisher_txt',
                dest: 'kq_meta_publisher_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_references_txt',
                dest: 'kq_meta_references_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_relation_txt',
                dest: 'kq_meta_relation_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_replaces_txt',
                dest: 'kq_meta_replaces_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_requires_txt',
                dest: 'kq_meta_requires_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_rights_txt',
                dest: 'kq_meta_rights_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_rightsHolder_txt',
                dest: 'kq_meta_rightsHolder_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_source_txt',
                dest: 'kq_meta_source_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_spatial_txt',
                dest: 'kq_meta_spatial_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_subject_txt',
                dest: 'kq_meta_subject_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_tableOfContents_txt',
                dest: 'kq_meta_tableOfContents_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_temporal_txt',
                dest: 'kq_meta_temporal_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_title_txt',
                dest: 'kq_meta_title_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_type_txt',
                dest: 'kq_meta_type_txt'
            },
            {
                source: 'uri_http_purl_org_dc_terms_valid_txt',
                dest: 'kq_meta_valid_txt'
            },

            # Copy a bunch of different fields into one for easy searching
            {
                source: 'kq_sys_full_text_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_contributor_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_coverage_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_creator_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_description_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_format_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_identifier_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_language_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_publisher_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_relation_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_source_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_subject_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_title_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_type_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_abstract_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_alternative_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_contributor_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_coverage_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_creator_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_description_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_format_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_identifier_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_language_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_mediator_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_medium_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_provenance_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_publisher_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_rights_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_rightsHolder_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_source_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_subject_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_tableOfContents_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_title_txt',
                dest: Fields::SEARCH_ALL
            },
            {
                source: 'uri_http_purl_org_dc_terms_type_txt',
                dest: Fields::SEARCH_ALL
            },

            # Create a string version of various fields for faceting
            {
                source: 'kq_sys_collection_key_s',
                dest: 'kq_collection_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_contributor_txt',
                dest: 'kq_contributor_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_contributor_txt',
                dest: 'kq_contributor_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_coverage_txt',
                dest: 'kq_coverage_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_coverage_txt',
                dest: 'kq_coverage_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_creator_txt',
                dest: 'kq_creator_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_creator_txt',
                dest: 'kq_creator_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_date_txt',
                dest: 'kq_date_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_date_txt',
                dest: 'kq_date_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_format_txt',
                dest: 'kq_format_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_format_txt',
                dest: 'kq_format_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_language_txt',
                dest: 'kq_language_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_language_txt',
                dest: 'kq_language_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_publisher_txt',
                dest: 'kq_publisher_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_publisher_txt',
                dest: 'kq_publisher_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_source_txt',
                dest: 'kq_source_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_source_txt',
                dest: 'kq_source_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_subject_txt',
                dest: 'kq_subject_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_subject_txt',
                dest: 'kq_subject_facet'
            },
            {
                source: 'uri_http_purl_org_dc_elements_1_1_type_txt',
                dest: 'kq_type_facet'
            },
            {
                source: 'uri_http_purl_org_dc_terms_type_txt',
                dest: 'kq_type_facet'
            }
        ],
        dynamicFields: [
            {
                name: '*_facet',
                type: 'string',
                stored: true,
                indexed: true,
                multiValued: true,
                docValues: true
            }
        ]
    }

    @@client = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url].chomp('/') +
                                 '/' + Kumquat::Application.kumquat_config[:solr_collection])

    ##
    # @return RSolr
    #
    def self.client
      @@client
    end

    ##
    # Gets the Solr-compatible field name for a given predicate.
    #
    # @param predicate string
    #
    def self.field_name_for_predicate(predicate)
      # convert all non-alphanumerics to underscores and then replace
      # repeating underscores with a single underscore
      'uri_' + predicate.to_s.gsub(/[^0-9a-z ]/i, '_').gsub(/\_+/, '_') + '_txt'
    end

    def initialize
      @http = HTTPClient.new
      @url = Kumquat::Application.kumquat_config[:solr_url].chomp('/') + '/' +
          Kumquat::Application.kumquat_config[:solr_collection]
    end

    ##
    # Creates the set of fields needed by the application. For this to work,
    # Solr must be using the ManagedIndexSchemaFactory.
    #
    # @return HTTP::Message or nil if there were no fields to create
    #
    def update_schema
      # http://mirrors.advancedhosters.com/apache/lucene/solr/ref-guide/apache-solr-ref-guide-5.0.pdf
      # https://cwiki.apache.org/confluence/display/solr/Schema+API
      # http://wiki.apache.org/solr/SchemaRESTAPI
      # TODO: Solr 5.1 allows updating existing fields in the schema
      # get the current list of fields
      response = @http.get("#{@url}/schema")
      struct = JSON.parse(response.body)

      # Solr will throw an error if we try to add a field that already exists,
      # so send it only fields that don't already exist.
      if SCHEMA[:dynamicFields]
          dynamic_fields_to_add = SCHEMA[:dynamicFields].reject do |kf|
              struct['schema']['dynamicFields'].
                  map{ |sf| sf['name'] }.include?(kf[:name])
          end
        post_fields('add-dynamic-field', dynamic_fields_to_add)
      end
      if SCHEMA[:fields]
        fields_to_add = SCHEMA[:fields].reject do |kf|
          struct['schema']['fields'].map{ |sf| sf['name'] }.include?(kf[:name])
        end
        post_fields('add-field', fields_to_add)
      end
      if SCHEMA[:copyFields]
        copy_fields_to_add = SCHEMA[:copyFields].reject do |kf|
          struct['schema']['copyFields'].
              map{ |sf| "#{sf['source']}-#{sf['dest']}" }.
              include?("#{kf[:source]}-#{kf[:dest]}")
        end
        post_fields('add-copy-field', copy_fields_to_add)
      end
    end

    private

    def post_fields(key, fields)
      if fields.any?
        json = JSON.generate({ key => fields })
        response = @http.post("#{@url}/schema", json,
                             { 'Content-Type' => 'application/json' })
        message = JSON.parse(response.body)
        if message['errors']
          puts message['errors']
          raise 'Failed to update Solr schema'
        end
      end
    end

  end

end
