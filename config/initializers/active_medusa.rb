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
  config.solr_parent_uri_field = Solr::Fields::PARENT_URI
  config.solr_uri_field = Solr::Fields::URI
  config.solr_uuid_field = Solr::Fields::UUID
  config.solr_default_search_field = Solr::Fields::SEARCH_ALL
  # config.solr_default_facetable_fields is set in an after_initialize hook in
  # application.rb; it can't be done here as ActiveRecord hasn't been
  # initialized yet
end
