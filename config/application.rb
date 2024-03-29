require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kumquat

  NAMESPACE_URI = 'http://kumquat.library.illinois.edu/'

  ##
  # "System objects" used by the application in the subject-predicate-object
  # sense. These will be appended to NAMESPACE_URI.
  #
  class RDFObjects
    DERIVATIVE_BYTESTREAM = 'Bytestream/Type/Derivative'
    MASTER_BYTESTREAM = 'Bytestream/Type/Master'
    ORIGINAL_SHAPE = 'Bytestream/Shape/Original'
    SQUARE_SHAPE = 'Bytestream/Shape/Square'
  end

  ##
  # "System predicates" used by the application in the
  # subject-predicate-object sense. These will be appended to NAMESPACE_URI.
  #
  class RDFPredicates
    BYTE_SIZE = 'byteSize'
    BYTESTREAM_SHAPE = 'bytestreamShape'
    BYTESTREAM_TYPE = 'bytestreamType'
    BYTESTREAM_URI = 'hasBytestream'
    CLASS = 'hasClass'
    COLLECTION_KEY = 'collectionKey'
    DATE = 'date'
    FULL_TEXT = 'fullText'
    HEIGHT = 'height'
    IS_MEMBER_OF_COLLECTION = 'isMemberOfCollection'
    IS_MEMBER_OF_ITEM = 'isMemberOfItem'
    PAGE_INDEX = 'pageIndex'
    PARENT_URI = 'hasParent'
    PUBLISHED = 'published'
    WEB_ID = 'webID'
    WIDTH = 'width'
  end

  class Application < Rails::Application

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

    config.active_job.queue_adapter = :delayed_job

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths << File.join(Rails.root, 'helpers/admin')
    config.autoload_paths << File.join(Rails.root, 'jobs')
    config.autoload_paths << File.join(Rails.root, 'lib')
    # TODO: why is this necessary? Without it, sometimes the following occurs:
    # Repository::Collection.db_counterpart: A copy of Repository::Collection has been removed from the module tree but is still active!
    config.autoload_once_paths << File.join(Rails.root, 'app/models')

    config.after_initialize do
      # the rest of the ActiveMedusa configuration is in
      # config/initializers/active_medusa.rb
      ActiveMedusa::Configuration.instance.solr_default_facetable_fields =
          Facet.all.map{ |f| f.solr_field }
    end
  end
end
