# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Roles
roles = {}
roles[:admin] = Role.create!(key: 'admin', name: 'Administrators')
roles[:cataloger] = Role.create!(key: 'cataloger', name: 'Catalogers')
roles[:everybody] = Role.create!(key: 'everybody', name: 'Everybody')

# Permissions
Permission.create!(key: 'collections.create',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'collections.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'collections.update',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'control_panel.access',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'roles.create',
                   roles: [roles[:admin]])
Permission.create!(key: 'roles.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'roles.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'settings.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.create',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.update_self',
                   roles: [roles[:admin], roles[:everybody]])
Permission.create!(key: 'users.disable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.enable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.view',
                   roles: [roles[:admin], roles[:cataloger]])

# RDF Predicates
# http://purl.org/dc/elements/1.1/
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/contributor',
                         label: 'Contributor',
                         solr_field: 'kq_contributor',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/coverage',
                         label: 'Coverage',
                         solr_field: 'kq_coverage',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/creator',
                         label: 'Creator',
                         solr_field: 'kq_creator',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/date',
                         label: 'Date',
                         solr_field: 'kq_date',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/description',
                         label: 'Description',
                         solr_field: 'kq_description',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/format',
                         label: 'Format',
                         solr_field: 'kq_format',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/identifier',
                         label: 'Identifier',
                         solr_field: 'kq_identifier',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/language',
                         label: 'Language',
                         solr_field: 'kq_language',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/publisher',
                         label: 'Publisher',
                         solr_field: 'kq_publisher',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/relation',
                         label: 'Relation',
                         solr_field: 'kq_relation',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/rights',
                         label: 'Rights',
                         solr_field: 'kq_rights',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/source',
                         label: 'Source',
                         solr_field: 'kq_source',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/subject',
                         label: 'Subject',
                         solr_field: 'kq_subject',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/title',
                         label: 'Title',
                         solr_field: 'kq_title',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/type',
                         label: 'Type',
                         solr_field: 'kq_type',
                         deletable: false)

# http://purl.org/dc/terms/
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/abstract',
                         label: 'Abstract',
                         solr_field: 'kq_abstract',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accessRights',
                         label: 'Access Rights',
                         solr_field: 'kq_accessRights',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualMethod',
                         label: 'Accrual Method',
                         solr_field: 'kq_accrualMethod',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualPeriodicity',
                         label: 'Accrual Periodicity',
                         solr_field: 'kq_accrualPeriodicity',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualPolicy',
                         label: 'Accrual Policy',
                         solr_field: 'kq_accrualPolicy',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/alternative',
                         label: 'Alternative Title',
                         solr_field: 'kq_alternative',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/audience',
                         label: 'Audience',
                         solr_field: 'kq_audience',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/available',
                         label: 'Date Available',
                         solr_field: 'kq_available',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/bibliographicCitation',
                         label: 'Bibliographic Citation',
                         solr_field: 'kq_bibliographicCitation',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/conformsTo',
                         label: 'Conforms To',
                         solr_field: 'kq_conformsTo',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/contributor',
                         label: 'Contributor',
                         solr_field: 'kq_contributor',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/coverage',
                         label: 'Coverage',
                         solr_field: 'kq_coverage',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/created',
                         label: 'Date Created',
                         solr_field: 'kq_created',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/creator',
                         label: 'Creator',
                         solr_field: 'kq_creator',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/date',
                         label: 'Date',
                         solr_field: 'kq_date',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateAccepted',
                         label: 'Date Accepted',
                         solr_field: 'kq_dateAccepted',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateCopyrighted',
                         label: 'Date Copyrighted',
                         solr_field: 'kq_dateCopyrighted',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateSubmitted',
                         label: 'Date Submitted',
                         solr_field: 'kq_dateSubmitted',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/description',
                         label: 'Description',
                         solr_field: 'kq_description',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/educationLevel',
                         label: 'Education Level',
                         solr_field: 'kq_educationLevel',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/extent',
                         label: 'Extent',
                         solr_field: 'kq_extent',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/format',
                         label: 'Format',
                         solr_field: 'kq_format',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasFormat',
                         label: 'Has Format',
                         solr_field: 'kq_hasFormat',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasPart',
                         label: 'Has Part',
                         solr_field: 'kq_hasPart',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasVersion',
                         label: 'Has Version',
                         solr_field: 'kq_hasVersion',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/identifier',
                         label: 'Identifier',
                         solr_field: 'kq_identifier',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/instructionalMethod',
                         label: 'Instructional Method',
                         solr_field: 'kq_instructionalMethod',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isFormatOf',
                         label: 'Is Format Of',
                         solr_field: 'kq_isFormatOf',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isPartOf',
                         label: 'Is Part Of',
                         solr_field: 'kq_isPartOf',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isReferencedBy',
                         label: 'Is Referenced By',
                         solr_field: 'kq_isReferencedBy',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isReplacedBy',
                         label: 'Is Replaced By',
                         solr_field: 'kq_isReplacedBy',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isRequiredBy',
                         label: 'Is Required By',
                         solr_field: 'kq_isRequiredBy',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/issued',
                         label: 'Date Issued',
                         solr_field: 'kq_issued',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isVersionOf',
                         label: 'Is Version Of',
                         solr_field: 'kq_isVersionOf',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/language',
                         label: 'Language',
                         solr_field: 'kq_language',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/license',
                         label: 'License',
                         solr_field: 'kq_license',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/mediator',
                         label: 'Mediator',
                         solr_field: 'kq_mediator',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/medium',
                         label: 'Medium',
                         solr_field: 'kq_medium',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/modified',
                         label: 'Date Modified',
                         solr_field: 'kq_modified',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/provenance',
                         label: 'Provenance',
                         solr_field: 'kq_provenance',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/publisher',
                         label: 'Publisher',
                         solr_field: 'kq_publisher',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/references',
                         label: 'References',
                         solr_field: 'kq_references',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/relation',
                         label: 'Relation',
                         solr_field: 'kq_relation',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/replaces',
                         label: 'Replaces',
                         solr_field: 'kq_replaces',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/requires',
                         label: 'Requires',
                         solr_field: 'kq_requires',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/rights',
                         label: 'Rights',
                         solr_field: 'kq_rights',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/rightsHolder',
                         label: 'Rights Holder',
                         solr_field: 'kq_rightsHolder',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/source',
                         label: 'Source',
                         solr_field: 'kq_source',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/spatial',
                         label: 'Spatial Coverage',
                         solr_field: 'kq_spatial',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/subject',
                         label: 'Subject',
                         solr_field: 'kq_subject',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/tableOfContents',
                         label: 'Table Of Contents',
                         solr_field: 'kq_tableOfContents',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/temporal',
                         label: 'Temporal Coverage',
                         solr_field: 'kq_temporal',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/title',
                         label: 'Title',
                         solr_field: 'kq_title',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/type',
                         label: 'Type',
                         solr_field: 'kq_type',
                         deletable: false)
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/valid',
                         label: 'Date Valid',
                         solr_field: 'kq_valid',
                         deletable: false)

# URI Prefixes
DB::URIPrefix.create!(prefix: 'dc',
                      uri: 'http://purl.org/dc/elements/1.1/')
DB::URIPrefix.create!(prefix: 'dcterms',
                      uri: 'http://purl.org/dc/terms/')
DB::URIPrefix.create!(prefix: 'foaf',
                      uri: 'http://xmlns.com/foaf/0.1/')
DB::URIPrefix.create!(prefix: 'rdfs',
                      uri: 'http://www.w3.org/2000/01/rdf-schema#')
DB::URIPrefix.create!(prefix: 'rdf',
                      uri: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')

if Rails.env.development?

  # Users
  users = {}
  users[:admin] = User.create!(
      username: 'admin',
      roles: [roles[:admin]])
  users[:cataloger] = User.create!(
      username: 'cataloger',
      roles: [roles[:cataloger]])
  users[:disabled] = User.create!(
      username: 'disabled',
      roles: [roles[:cataloger]])

end
