source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'backburner'
gem 'bcrypt', '~> 3.1.7' # Use ActiveModel has_secure_password
gem 'bootstrap-sass', '~> 3.3.4.1'
gem 'font-awesome-sass', '~> 4.3.0'
gem 'httpclient', :git => 'git://github.com/adolski/httpclient.git'
gem 'jquery-cookie-rails'
gem 'jquery-rails'
gem 'json-ld'
gem 'local_time'
gem 'mime-types'
gem 'omniauth'
gem 'omniauth-password', :git => 'git://github.com/wearepistachio/omniauth-password.git'
gem 'pg'
gem 'rails_autolink'
gem 'rdf'
gem 'rdf-turtle'
gem 'rdf-rdfxml'
gem 'rsolr'
gem 'sprockets-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
gem 'yomu' # text extraction from PDF, .docx, etc.

group :development do
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-rvm'
  gem 'puma' # puma supports chunked responses
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'passenger'
end
