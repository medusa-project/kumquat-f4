require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kumquat
  class Application < Rails::Application

    NAMESPACE_URI = 'http://example.org/' # TODO: change this

    ##
    # "System objects" used by the application in the subject-predicate-object
    # sense. These will be appended to NAMESPACE_URI.
    #
    class RDFObjects
      BYTESTREAM = 'bytestream'
      COLLECTION = 'collection'
      ITEM = 'item'
    end

    ##
    # "System predicates" used by the application in the
    # subject-predicate-object sense. These will be appended to NAMESPACE_URI.
    #
    class RDFPredicates
      BYTESTREAM_TYPE = 'bytestreamType'
      CLASS = 'class'
      COLLECTION_KEY = 'collectionKey'
      FULL_TEXT = 'fullText'
      HEIGHT = 'height'
      MASTER_BYTESTREAM_URI = 'hasMasterBytestream'
      PAGE_INDEX = 'pageIndex'
      PARENT_UUID = 'parentUUID'
      WEB_ID = 'webID'
      WIDTH = 'width'
    end

    attr_accessor :kumquat_config

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths << File.join(Rails.root, 'lib')
  end
end
