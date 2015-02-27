# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Make the logger available from initializers as well as disable log files.
Rails.logger = Logger.new(STDOUT)

# Initialize the Rails application.
Rails.application.initialize!
