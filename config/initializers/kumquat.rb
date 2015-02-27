Kumquat::Application.kumquat_config =
    YAML.load_file(File.join(Rails.root, 'config', 'kumquat.yml'))[Rails.env]

# create/update the Fedora indexing transformation needed by the application
Rails.logger.info 'Creating Fedora indexing transform'
begin
  Fedora::Repository.new.apply_indexing_transform
rescue HTTPClient::BadResponseError => e
  Rails.logger.fatal "#{e.message} (is the Fedora URL correct in kumquat.yml?)"
  exit
rescue => e
  Rails.logger.fatal "#{e.message} (is Fedora running, and is its URL correct in kumquat.yml?)"
  exit
end

# update the Solr schema
Rails.logger.info 'Updating the Solr schema'
begin
  Solr::Solr.new.update_schema
rescue HTTPClient::BadResponseError => e
  Rails.logger.fatal "#{e.message} (is the Solr URL correct in kumquat.yml?)"
  exit
rescue => e
  Rails.logger.fatal "#{e.message} (is Solr running, and is its URL correct in kumquat.yml?)"
  exit
end