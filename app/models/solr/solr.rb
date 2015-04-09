module Solr

  class Solr

    # The values of this hash will be POSTed or PUT as-is to Solr's schema API
    # endpoint.
    SCHEMA = {
        copyFields: [
            # Map various fields into Kumquat's own schema. The main purpose
            # of this for now is to normalize the DC elements and terms.
            {
                source: 'dc_contributor',
                dest: 'kq_contributor'
            },
            {
                source: 'dc_coverage',
                dest: 'kq_coverage'
            },
            {
                source: 'dc_creator',
                dest: 'kq_creator'
            },
            {
                source: 'dc_date',
                dest: 'kq_date'
            },
            {
                source: 'dc_description',
                dest: 'kq_description'
            },
            {
                source: 'dc_format',
                dest: 'kq_format'
            },
            {
                source: 'dc_identifier',
                dest: 'kq_identifier'
            },
            {
                source: 'dc_language',
                dest: 'kq_language'
            },
            {
                source: 'dc_publisher',
                dest: 'kq_publisher'
            },
            {
                source: 'dc_relation',
                dest: 'kq_relation'
            },
            {
                source: 'dc_rights',
                dest: 'kq_rights'
            },
            {
                source: 'dc_source',
                dest: 'kq_source'
            },
            {
                source: 'dc_subject',
                dest: 'kq_subject'
            },
            {
                source: 'dc_title',
                dest: 'kq_title'
            },
            {
                source: 'dc_type',
                dest: 'kq_type'
            },
            {
                source: 'dcterm_abstract',
                dest: 'kq_abstract'
            },
            {
                source: 'dcterm_accessRights',
                dest: 'kq_accessRights'
            },
            {
                source: 'dcterm_accrualMethod',
                dest: 'kq_accrualMethod'
            },
            {
                source: 'dcterm_accrualPeriodicity',
                dest: 'kq_accrualPeriodicity'
            },
            {
                source: 'dcterm_accrualPolicy',
                dest: 'kq_accrualPolicy'
            },
            {
                source: 'dcterm_alternative',
                dest: 'kq_alternative'
            },
            {
                source: 'dcterm_audience',
                dest: 'kq_audience'
            },
            {
                source: 'dcterm_available',
                dest: 'kq_available'
            },
            {
                source: 'dcterm_bibliographicCitation',
                dest: 'kq_bibliographicCitation'
            },
            {
                source: 'dcterm_conformsTo',
                dest: 'kq_conformsTo'
            },
            {
                source: 'dcterm_contributor',
                dest: 'kq_contributor'
            },
            {
                source: 'dcterm_coverage',
                dest: 'kq_coverage'
            },
            {
                source: 'dcterm_created',
                dest: 'kq_created'
            },
            {
                source: 'dcterm_creator',
                dest: 'kq_creator'
            },
            {
                source: 'dcterm_date',
                dest: 'kq_date'
            },
            {
                source: 'dcterm_dateAccepted',
                dest: 'kq_dateAccepted'
            },
            {
                source: 'dcterm_dateCopyrighted',
                dest: 'kq_dateCopyrighted'
            },
            {
                source: 'dcterm_dateSubmitted',
                dest: 'kq_dateSubmitted'
            },
            {
                source: 'dcterm_description',
                dest: 'kq_description'
            },
            {
                source: 'dcterm_educationLevel',
                dest: 'kq_educationLevel'
            },
            {
                source: 'dcterm_extent',
                dest: 'kq_extent'
            },
            {
                source: 'dcterm_format',
                dest: 'kq_format'
            },
            {
                source: 'dcterm_hasFormat',
                dest: 'kq_hasFormat'
            },
            {
                source: 'dcterm_hasPart',
                dest: 'kq_hasPart'
            },
            {
                source: 'dcterm_hasVersion',
                dest: 'kq_hasVersion'
            },
            {
                source: 'dcterm_identifier',
                dest: 'kq_identifier'
            },
            {
                source: 'dcterm_instructionalMethod',
                dest: 'kq_instructionalMethod'
            },
            {
                source: 'dcterm_isFormatOf',
                dest: 'kq_isFormatOf'
            },
            {
                source: 'dcterm_isPartOf',
                dest: 'kq_isPartOf'
            },
            {
                source: 'dcterm_isReferencedBy',
                dest: 'kq_isReferencedBy'
            },
            {
                source: 'dcterm_isReplacedBy',
                dest: 'kq_isReplacedBy'
            },
            {
                source: 'dcterm_isRequiredBy',
                dest: 'kq_isRequiredBy'
            },
            {
                source: 'dcterm_issued',
                dest: 'kq_issued'
            },
            {
                source: 'dcterm_isVersionOf',
                dest: 'kq_language'
            },
            {
                source: 'dcterm_language',
                dest: 'kq_language'
            },
            {
                source: 'dcterm_license',
                dest: 'kq_license'
            },
            {
                source: 'dcterm_mediator',
                dest: 'kq_mediator'
            },
            {
                source: 'dcterm_MediaType',
                dest: 'kq_media_type'
            },
            {
                source: 'dcterm_MediaType',
                dest: 'kq_system_media_type'
            },
            {
                source: 'dcterm_medium',
                dest: 'kq_medium'
            },
            {
                source: 'dcterm_modified',
                dest: 'kq_modified'
            },
            {
                source: 'dcterm_provenance',
                dest: 'kq_provenance'
            },
            {
                source: 'dcterm_publisher',
                dest: 'kq_publisher'
            },
            {
                source: 'dcterm_references',
                dest: 'kq_references'
            },
            {
                source: 'dcterm_relation',
                dest: 'kq_relation'
            },
            {
                source: 'dcterm_replaces',
                dest: 'kq_replaces'
            },
            {
                source: 'dcterm_requires',
                dest: 'kq_requires'
            },
            {
                source: 'dcterm_rights',
                dest: 'kq_rights'
            },
            {
                source: 'dcterm_rightsHolder',
                dest: 'kq_rightsHolder'
            },
            {
                source: 'dcterm_source',
                dest: 'kq_source'
            },
            {
                source: 'dcterm_spatial',
                dest: 'kq_spatial'
            },
            {
                source: 'dcterm_subject',
                dest: 'kq_subject'
            },
            {
                source: 'dcterm_tableOfContents',
                dest: 'kq_tableOfContents'
            },
            {
                source: 'dcterm_temporal',
                dest: 'kq_temporal'
            },
            {
                source: 'dcterm_title',
                dest: 'kq_title'
            },
            {
                source: 'dcterm_type',
                dest: 'kq_type'
            },
            {
                source: 'dcterm_valid',
                dest: 'kq_valid'
            },

            # Copy a bunch of different fields into one for easy searching
            {
                source: 'kq_system_full_text',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_contributor',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_coverage',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_creator',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_description',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_format',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_identifier',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_language',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_publisher',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_relation',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_source',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_subject',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_title',
                dest: 'kq_searchall'
            },
            {
                source: 'dc_type',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_abstract',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_alternative',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_contributor',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_coverage',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_creator',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_description',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_format',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_identifier',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_language',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_mediator',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_medium',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_provenance',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_publisher',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_rights',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_rightsHolder',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_source',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_subject',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_tableOfContents',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_title',
                dest: 'kq_searchall'
            },
            {
                source: 'dcterm_type',
                dest: 'kq_searchall'
            },

            # Create a string version of various fields for faceting
            {
                source: 'dc_contributor',
                dest: 'kq_contributor_facet'
            },
            {
                source: 'dcterm_contributor',
                dest: 'kq_contributor_facet'
            },
            {
                source: 'dc_coverage',
                dest: 'kq_coverage_facet'
            },
            {
                source: 'dcterm_coverage',
                dest: 'kq_coverage_facet'
            },
            {
                source: 'dc_creator',
                dest: 'kq_creator_facet'
            },
            {
                source: 'dcterm_creator',
                dest: 'kq_creator_facet'
            },
            {
                source: 'dc_date',
                dest: 'kq_date_facet'
            },
            {
                source: 'dcterm_date',
                dest: 'kq_date_facet'
            },
            {
                source: 'dc_format',
                dest: 'kq_format_facet'
            },
            {
                source: 'dcterm_format',
                dest: 'kq_format_facet'
            },
            {
                source: 'dc_language',
                dest: 'kq_language_facet'
            },
            {
                source: 'dcterm_language',
                dest: 'kq_language_facet'
            },
            {
                source: 'dc_publisher',
                dest: 'kq_publisher_facet'
            },
            {
                source: 'dcterm_publisher',
                dest: 'kq_publisher_facet'
            },
            {
                source: 'dc_source',
                dest: 'kq_source_facet'
            },
            {
                source: 'dcterm_source',
                dest: 'kq_source_facet'
            },
            {
                source: 'dc_subject',
                dest: 'kq_subject_facet'
            },
            {
                source: 'dcterm_subject',
                dest: 'kq_subject_facet'
            },
            {
                source: 'dc_type',
                dest: 'kq_type_facet'
            },
            {
                source: 'dcterm_type',
                dest: 'kq_type_facet'
            }
        ],
        dynamicFields: [
            {
                name: '*_facet',
                type: 'string',
                stored: true,
                indexed: true,
                required: true,
                multiValued: true,
                docValues: true
            }
        ],
        fields: [
            # system fields
            {
                name: 'uuid',
                type: 'string',
                stored: true,
                indexed: true,
                required: true,
                multiValued: false
            },
            {
                name: 'kq_system_class',
                type: 'string',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_collection_key',
                type: 'string',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_full_text',
                type: 'text_general',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_height',
                type: 'int',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_media_type',
                type: 'string',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_page_index',
                type: 'int',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_parent_uri',
                type: 'string',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_published',
                type: 'boolean',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_web_id',
                type: 'string',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },
            {
                name: 'kq_system_width',
                type: 'int',
                stored: true,
                indexed: true,
                required: false,
                multiValued: false
            },

            # normalized metadata fields
            {
                name: 'kq_abstract',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_accessRights',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_accrualMethod',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_accrualPeriodicity',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_accrualPolicy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_alternativeTitle',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_audience',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_available',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_bibliographicCitation',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_conformsTo',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_contributor',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_coverage',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_created',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_creator',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_date',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_dateAccepted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_dateCopyrighted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_dateSubmitted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_description',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_educationLevel',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_extent',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_format',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_hasFormat',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_hasPart',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_hasVersion',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_identifier',
                type: 'string',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_instructionalMethod',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isFormatOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isPartOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isReferencedBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isReplacedBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isRequiredBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_issued',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_isVersionOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_language',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_license',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_mediator',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_media_type',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_medium',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_modified',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_provenance',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_publisher',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_references',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_relation',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_replaces',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_requires',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_rights',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_rightsHolder',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_searchall',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_source',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_spatial',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_subject',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_tableOfContents',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_temporal',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_title',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_type',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'kq_valid',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },

            # Dublin Core fields (populated by F4 index transform)
            {
                name: 'dc_contributor',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_coverage',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_creator',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_date',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_description',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_format',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_identifier',
                type: 'string',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_language',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_publisher',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_relation',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_rights',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_source',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_subject',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_title',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dc_type',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_abstract',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_accessRights',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_accrualMethod',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_accrualPeriodicity',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_accrualPolicy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_alternative',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_audience',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_available',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_bibliographicCitation',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_conformsTo',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_contributor',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_coverage',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_created',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_creator',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_date',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_dateAccepted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_dateCopyrighted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_dateSubmitted',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_description',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_educationLevel',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_extent',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_format',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_hasFormat',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_hasPart',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_hasVersion',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_identifier',
                type: 'string',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_instructionalMethod',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isFormatOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isPartOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isReferencedBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isReplacedBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isRequiredBy',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_issued',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_isVersionOf',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_language',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_license',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_mediator',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_MediaType',
                type: 'string',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_medium',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_modified',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_provenance',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_publisher',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_references',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_relation',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_replaces',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_requires',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_rights',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_rightsHolder',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_source',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_spatial',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_subject',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_tableOfContents',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_temporal',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_title',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_type',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            },
            {
                name: 'dcterm_valid',
                type: 'text_general',
                stored: true,
                indexed: true,
                multiValued: true
            }
        ]
    }

    CLASS_KEY = :kq_system_class
    COLLECTION_KEY_KEY = :kq_system_collection_key
    # each of these requires a localized label (solr_field_*)
    FACET_FIELDS = [:kq_contributor_facet, :kq_coverage_facet,
                    :kq_creator_facet, :kq_date_facet, :kq_format_facet,
                    :kq_language_facet, :kq_publisher_facet, :kq_source_facet,
                    :kq_subject_facet, :kq_type_facet]
    FULL_TEXT_KEY = :kq_system_full_text
    HEIGHT_KEY = :kq_system_height
    MEDIA_TYPE_KEY = :kq_system_media_type
    PAGE_INDEX_KEY = :kq_system_page_index
    PARENT_URI_KEY = :kq_system_parent_uri
    PUBLISHED_KEY = :kq_system_published
    WEB_ID_KEY = :kq_system_web_id
    WIDTH_KEY = :kq_system_width

    @@client = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url].chomp('/') +
                                 '/' + Kumquat::Application.kumquat_config[:solr_collection])

    ##
    # @return RSolr
    #
    def self.client
      @@client
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
      url = Kumquat::Application.kumquat_config[:solr_url].chomp('/') + '/' +
          Kumquat::Application.kumquat_config[:solr_collection]
      http = HTTPClient.new
      response = http.get("#{url}/schema")
      struct = JSON.parse(response.body)

      # Solr will throw an error if we try to add a field that already exists,
      # so send it only fields that don't already exist.
      fields_to_add = SCHEMA[:fields].reject do |kf|
        struct['schema']['fields'].map{ |sf| sf['name'] }.include?(kf[:name])
      end
      copy_fields_to_add = SCHEMA[:copyFields].reject do |kf|
        struct['schema']['copyFields'].
            map{ |sf| "#{sf['source']}-#{sf['destination']}" }.
            include?("#{kf[:source]}-#{kf[:destination]}")
      end
      dynamic_fields_to_add = SCHEMA[:dynamicFields].reject do |kf|
        struct['schema']['dynamicFields'].
            map{ |sf| sf['name'] }.include?(kf[:name])
      end

      struct = {}
      struct['add-field'] = fields_to_add if fields_to_add.any?
      struct['add-copy-field'] = copy_fields_to_add if copy_fields_to_add.any?
      struct['add-dynamic-field'] = dynamic_fields_to_add if dynamic_fields_to_add.any?
      http.post("#{url}/schema", JSON.generate(struct),
                { 'Content-Type' => 'application/json' }) if struct.any?
    end

  end

end
