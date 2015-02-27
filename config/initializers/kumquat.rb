Kumquat::Application.kumquat_config =
    YAML.load_file(File.join(Rails.root, 'config', 'kumquat.yml'))[Rails.env]

# create/update the Fedora indexing transformation needed by the application
Rails.logger.info 'Creating Fedora indexing transform (config/initializers/kumquat.rb)'
begin
  Fedora::Repository.new.apply_indexing_transform
rescue HTTPClient::BadResponseError => e
  Rails.logger.fatal "#{e.message} (is the Fedora URL correct in kumquat.yml?)"
  exit
rescue => e
  Rails.logger.fatal "#{e.message} (is Fedora running, and is its URL correct in kumquat.yml?)"
  exit
end
