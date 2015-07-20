# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Options
Option.create!(key: Option::Key::ADMINISTRATOR_EMAIL,
               value: 'admin@example.org')
Option.create!(key: Option::Key::COPYRIGHT_STATEMENT,
               value: 'Copyright © 2015 My Great Organization. All rights reserved.')
Option.create!(key: Option::Key::FACET_TERM_LIMIT, value: 10)
Option.create!(key: Option::Key::OAI_PMH_ENABLED, value: true)
Option.create!(key: Option::Key::ORGANIZATION_NAME,
               value: 'My Great Organization')
Option.create!(key: Option::Key::WEBSITE_NAME,
               value: 'My Great Organization Digital Collections')
Option.create!(key: Option::Key::WEBSITE_INTRO_TEXT,
               value: "Behold our great collections, which are "\
               "rich in Vitamin C and guaranteed gluten-free.\n\n"\
               "Warning: may contain citrus.")
Option.create!(key: Option::Key::RESULTS_PER_PAGE, value: 30)

# Roles
roles = {}
roles[:admin] = Role.create!(key: 'admin', name: 'Administrators', required: true)
roles[:cataloger] = Role.create!(key: 'cataloger', name: 'Catalogers')
roles[:anybody] = Role.create!(key: 'anybody', name: 'Anybody', required: true)

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
                   roles: [roles[:admin], roles[:anybody]])
Permission.create!(key: 'users.disable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.enable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.view',
                   roles: [roles[:admin], roles[:cataloger]])

# Metadata profiles
profiles = {}
profiles[:default] = MetadataProfile.create!(name: 'Default Profile',
                                             default: true)

Triple.create!(predicate: 'http://purl.org/dc/terms/abstract',
               label: 'Abstract',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/accessRights',
               label: 'Access Rights',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/accrualMethod',
               label: 'Accrual Method',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/accrualPeriodicity',
               label: 'Accrual Periodicity',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/accrualPolicy',
               label: 'Accrual Policy',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/alternative',
               label: 'Alternative Title',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/audience',
               label: 'Audience',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/available',
               label: 'Date Available',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/bibliographicCitation',
               label: 'Bibliographic Citation',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/conformsTo',
               label: 'Conforms To',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/contributor',
               label: 'Contributor',
               facetable: true,
               facet_field: 'kq_contributor_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/coverage',
               label: 'Coverage',
               facetable: true,
               facet_field: 'kq_coverage_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/created',
               label: 'Date Created',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/creator',
               label: 'Creator',
               facetable: true,
               facet_field: 'kq_creator_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/date',
               label: 'Date',
               facetable: true,
               facet_field: 'kq_date_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/dateAccepted',
               label: 'Date Accepted',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/dateCopyrighted',
               label: 'Date Copyrighted',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/dateSubmitted',
               label: 'Date Submitted',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/description',
               label: 'Description',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/educationLevel',
               label: 'Education Level',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/extent',
               label: 'Extent',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/format',
               label: 'Format',
               facetable: true,
               facet_field: 'kq_format_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/hasFormat',
               label: 'Has Format',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/hasPart',
               label: 'Has Part',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/hasVersion',
               label: 'Has Version',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/identifier',
               label: 'Identifier',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/instructionalMethod',
               label: 'Instructional Method',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isFormatOf',
               label: 'Is Format Of',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isPartOf',
               label: 'Is Part Of',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isReferencedBy',
               label: 'Is Referenced By',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isReplacedBy',
               label: 'Is Replaced By',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isRequiredBy',
               label: 'Is Required By',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/issued',
               label: 'Date Issued',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/isVersionOf',
               label: 'Is Version Of',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/language',
               label: 'Language',
               facetable: true,
               facet_field: 'kq_language_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/license',
               label: 'License',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/mediator',
               label: 'Mediator',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/medium',
               label: 'Medium',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/modified',
               label: 'Date Modified',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/provenance',
               label: 'Provenance',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/publisher',
               label: 'Publisher',
               facetable: true,
               facet_field: 'kq_publisher_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/references',
               label: 'References',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/relation',
               label: 'Relation',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/replaces',
               label: 'Replaces',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/requires',
               label: 'Requires',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/rights',
               label: 'Rights',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/rightsHolder',
               label: 'Rights Holder',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/source',
               label: 'Source',
               facetable: true,
               facet_field: 'kq_source_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/spatial',
               label: 'Spatial Coverage',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/subject',
               label: 'Subject',
               facet_field: 'kq_subject_facet',
               facetable: true,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/tableOfContents',
               label: 'Table Of Contents',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/temporal',
               label: 'Temporal Coverage',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/title',
               label: 'Title',
               facetable: false,
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/type',
               label: 'Type',
               facetable: true,
               facet_field: 'kq_type_facet',
               metadata_profile: profiles[:default])
Triple.create!(predicate: 'http://purl.org/dc/terms/valid',
               label: 'Date Valid',
               facetable: false,
               metadata_profile: profiles[:default])

# Themes
Theme.create!(name: 'Built-In', required: true, default: true)

# URI Prefixes
URIPrefix.create!(prefix: 'dc',
                  uri: 'http://purl.org/dc/elements/1.1/')
URIPrefix.create!(prefix: 'dcterms',
                  uri: 'http://purl.org/dc/terms/')
URIPrefix.create!(prefix: 'foaf',
                  uri: 'http://xmlns.com/foaf/0.1/')
URIPrefix.create!(prefix: 'iana',
                  uri: 'http://www.iana.org/assignments/relation/')
URIPrefix.create!(prefix: 'ore',
                  uri: 'http://www.openarchives.org/ore/terms/')
URIPrefix.create!(prefix: 'rdfs',
                  uri: 'http://www.w3.org/2000/01/rdf-schema#')
URIPrefix.create!(prefix: 'rdf',
                  uri: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')

# Admin user
users = {}
users[:admin] = User.create!(
    email: 'admin@example.org',
    username: 'admin',
    password: 'kumquats4ever',
    roles: [roles[:admin]])

if Rails.env.development? or Rails.env.uiuc_development?

  # Non-admin users
  users[:cataloger] = User.create!(
      email: 'cataloger@example.org',
      username: 'cataloger',
      password: 'password',
      enabled: true,
      roles: [roles[:cataloger]])
  users[:disabled] = User.create!(
      email: 'disabled@example.org',
      password: 'password',
      username: 'disabled',
      enabled: false,
      roles: [roles[:cataloger]])

end

if Rails.env.start_with?('uiuc')

  # Themes
  Theme.create!(name: 'UIUC', default: true)

  # Overwrite some default options for internal demo purposes
  option = Option.find_by_key(Option::Key::COPYRIGHT_STATEMENT)
  option.value = 'Copyright © 2015 The Board of Trustees at the '\
  'University of Illinois. All rights reserved.'
  option.save!

  option = Option.find_by_key(Option::Key::ORGANIZATION_NAME)
  option.value = 'University of Illinois at Urbana-Champaign Library'
  option.save!

  option = Option.find_by_key(Option::Key::WEBSITE_NAME)
  option.value = 'University of Illinois at Urbana-Champaign Library Digital '\
  'Image Collections'
  option.save!

  option = Option.find_by_key(Option::Key::WEBSITE_INTRO_TEXT)
  option.value = "The digital collections of the Library of the University of "\
  "Illinois at Urbana-Champaign are built from the rich special collections "\
  "of its Rare Book & Manuscript Library; Illinois History and Lincoln "\
  "Collection, University Archives; Map Library; and Sousa Archives & Center "\
  "for American Music, among other units.\n\n"\
  "The collections include historic photographs; maps; prints and "\
  "watercolors; bookplates; architectural drawings and blueprints; letters "\
  "and other archival materials; videos; political cartoons; and "\
  "advertisements. They cover a wide range of subject areas including "\
  "Illinois and American history, music, theater history, and the history of "\
  "the University of Illinois, among others. The Library’s digital "\
  "collections provide access to some of its most unique holdings for "\
  "teaching, learning, and research for students, scholars and the general "\
  "public.\n\n"\
  "The Library contributes collaboratively to local, national, and "\
  "international digital initiatives, such as the Digital Public Library of "\
  "America and the Biodiversity Heritage Library."
  option.save!

end
