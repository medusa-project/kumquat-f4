ActiveMedusa::Configuration.new do |config|
  kq_config = YAML.load_file(File.join(Rails.root, 'config', 'kumquat.yml'))[Rails.env]

  config.fedora_url = kq_config[:fedora_url]
  config.logger = Rails.logger
  config.class_predicate = 'http://example.org/hasClass'
  config.solr_url = kq_config[:solr_url]
  config.solr_core = kq_config[:solr_core]
  config.solr_more_like_this_endpoint = '/mlt'
  config.solr_class_field = Solr::Fields::CLASS
  config.solr_uri_field = :id
  config.solr_uuid_field = Solr::Fields::UUID
  config.solr_default_search_field = Solr::Fields::SEARCH_ALL
  config.solr_facet_fields = Solr::Fields::FACET_FIELDS
end
