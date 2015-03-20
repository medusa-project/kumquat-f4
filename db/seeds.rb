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
                         label: 'Contributor')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/coverage',
                         label: 'Coverage')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/creator',
                         label: 'Creator')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/date',
                         label: 'Date')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/description',
                         label: 'Description')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/format',
                         label: 'Format')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/identifier',
                         label: 'Identifier')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/language',
                         label: 'Language')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/publisher',
                         label: 'Publisher')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/relation',
                         label: 'Relation')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/rights',
                         label: 'Rights')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/source',
                         label: 'Source')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/subject',
                         label: 'Subject')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/title',
                         label: 'Title')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/elements/1.1/type',
                         label: 'Type')

# http://purl.org/dc/terms/
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/abstract',
                         label: 'Abstract')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accessRights',
                         label: 'Access Rights')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualMethod',
                         label: 'Accrual Method')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualPeriodicity',
                         label: 'Accrual Periodicity')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/accrualPolicy',
                         label: 'Accrual Policy')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/alternative',
                         label: 'Alternative Title')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/audience',
                         label: 'Audience')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/available',
                         label: 'Date Available')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/bibliographicCitation',
                         label: 'Bibliographic Citation')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/conformsTo',
                         label: 'Conforms To')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/contributor',
                         label: 'Contributor')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/coverage',
                         label: 'Coverage')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/created',
                         label: 'Date Created')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/creator',
                         label: 'Creator')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/date',
                         label: 'Date')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateAccepted',
                         label: 'Date Accepted')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateCopyrighted',
                         label: 'Date Copyrighted')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/dateSubmitted',
                         label: 'Date Submitted')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/description',
                         label: 'Description')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/educationLevel',
                         label: 'Education Level')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/extent',
                         label: 'Extent')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/format',
                         label: 'Format')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasFormat',
                         label: 'Has Format')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasPart',
                         label: 'Has Part')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/hasVersion',
                         label: 'Has Version')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/identifier',
                         label: 'Identifier')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/instructionalMethod',
                         label: 'Instructional Method')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isFormatOf',
                         label: 'Is Format Of')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isPartOf',
                         label: 'Is Part Of')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isReferencedBy',
                         label: 'Is Referenced By')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isReplacedBy',
                         label: 'Is Replaced By')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isRequiredBy',
                         label: 'Is Required By')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/issued',
                         label: 'Date Issued')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/isVersionOf',
                         label: 'Is Version Of')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/language',
                         label: 'Language')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/license',
                         label: 'License')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/mediator',
                         label: 'Mediator')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/medium',
                         label: 'Medium')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/modified',
                         label: 'Date Modified')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/provenance',
                         label: 'Provenance')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/publisher',
                         label: 'Publisher')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/references',
                         label: 'References')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/relation',
                         label: 'Relation')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/replaces',
                         label: 'Replaces')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/requires',
                         label: 'Requires')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/rights',
                         label: 'Rights')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/rightsHolder',
                         label: 'Rights Holder')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/source',
                         label: 'Source')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/spatial',
                         label: 'Spatial Coverage')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/subject',
                         label: 'Subject')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/tableOfContents',
                         label: 'Table Of Contents')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/temporal',
                         label: 'Temporal Coverage')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/title',
                         label: 'Title')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/type',
                         label: 'Type')
DB::RDFPredicate.create!(uri: 'http://purl.org/dc/terms/valid',
                         label: 'Date Valid')

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
