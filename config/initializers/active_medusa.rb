=begin
ActiveMedusa::Configuration.new do |config|
  config.fedora_url = 'http://fedora-dev.library.illinois.edu:8080/fedora/rest/kumquat'
  config.logger = Rails.logger
  config.solr_url = 'http://solr-dev.library.illinois.edu:8983/solr'
  config.class_predicate = 'http://www.w3.org/2000/01/rdf-schema#Class'
  config.solr_core = 'kumquat'
  config.solr_more_like_this_endpoint = '/mlt'
  config.solr_class_field = Solr::Fields::CLASS
  config.solr_uri_field = :id
  config.solr_uuid_field = Solr::Fields::UUID
  config.solr_default_search_field = Solr::Fields::SEARCH_ALL
  config.solr_facet_fields = Solr::Fields::FACET_FIELDS
end
=end

require_relative 'kumquat'

ActiveMedusa::Configuration.new do |config|
  kq_config = YAML.load_file(File.join(Rails.root, 'config', 'kumquat.yml'))[Rails.env]
  config.fedora_url = kq_config[:fedora_url]
  config.logger = Rails.logger
  config.class_predicate = 'http://www.w3.org/2000/01/rdf-schema#Class'
  config.solr_url = kq_config[:solr_url]
  config.solr_core = kq_config[:solr_core]
  config.solr_more_like_this_endpoint = '/mlt'
  config.solr_class_field = Solr::Fields::CLASS
  config.solr_uri_field = :id
  config.solr_uuid_field = Solr::Fields::UUID
  config.solr_default_search_field = Solr::Fields::SEARCH_ALL
  config.solr_default_facet_fields = Solr::Fields::DEFAULT_FACET_FIELDS
end
