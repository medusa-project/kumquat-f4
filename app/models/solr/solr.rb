module Solr

  class Solr

    FIELDS = [
        {
            name: 'uuid',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'web_id',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_contributor',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_coverage',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_creator',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_date',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_description',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_format',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_identifier',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_language',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_publisher',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_relation',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_rights',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_source',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_subject',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_title',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dc_type',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_abstract',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_accessRights',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_accrualMethod',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_accrualPeriodicity',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_accrualPolicy',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_alternative',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_audience',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_available',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_bibliographicCitation',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_conformsTo',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_contributor',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_coverage',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_created',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_creator',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_date',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_dateAccepted',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_dateCopyrighted',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_dateSubmitted',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_description',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_educationLevel',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_extent',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_format',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_hasFormat',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_hasPart',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_hasVersion',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_identifier',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_instructionalMethod',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isFormatOf',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isPartOf',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isReferencedBy',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isReplacedBy',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isRequiredBy',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_issued',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_isVersionOf',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_language',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_license',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_mediator',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_medium',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_modified',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_provenance',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_publisher',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_references',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_relation',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_replaces',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_requires',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_rights',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_rightsHolder',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_source',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_spatial',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_subject',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_tableOfContents',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_temporal',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_title',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_type',
            type: 'text_general',
            stored: true,
            indexed: true
        },
        {
            name: 'dcterm_valid',
            type: 'text_general',
            stored: true,
            indexed: true
        }
    ]

    def initialize
      @http = HTTPClient.new
      @url = Kumquat::Application.kumquat_config[:solr_url].chomp('/')
    end

    def commit
      @http.get(@url + '/update?commit=true')
    end

    ##
    # Creates the set of fields needed by the application. For this to work,
    # Solr must be using the ManagedIndexSchemaFactory.
    #
    # @return HTTP::Message or nil if there were no fields to create
    #
    def update_schema
      # TODO: the Solr API doesn't allow it yet as of 4.10, but it would be
      # nice to be able to update existing fields in the schema.
      fields_url = @url + '/collection1/schema/fields'
      # get the current list of fields
      response = @http.get(fields_url)
      struct = JSON.parse(response.body)

      # Solr will throw an error if we try to add a field that already exists,
      # so get an array of fields that don't already exist.
      fields_to_add = FIELDS.reject do |kf|
        struct['fields'].map{ |sf| sf['name'] }.include?(kf[:name])
      end

      @http.post(fields_url, JSON.generate(fields_to_add),
                 { 'Content-Type' => 'application/json' }) if fields_to_add.any?
    end

  end

end