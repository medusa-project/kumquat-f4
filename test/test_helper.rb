ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require File.join(Rails.root, 'test', 'repo_fixtures', 'test_fixtures_import_delegate.rb')

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Helper methods

  def seed_repository
    delete_all_nodes
    importer = Import::Importer.new(TestFixturesImportDelegate.new)
    importer.import
    sleep 4 # wait for solr to catch up
    Solr::Solr.client.commit
    sleep 2 # wait for solr to catch up
  end

  private

  def delete_all_nodes
    url = Kumquat::Application.kumquat_config[:fedora_url]
    http = HTTPClient.new
    RDF::Reader.open(url) do |reader|
      reader.each_statement do |statement|
        if statement.predicate.to_s == 'http://www.w3.org/ns/ldp#contains' and
            !statement.object.to_s.include?('fedora:system')
          puts "Deleting #{statement.object.to_s}"
          http.delete(statement.object.to_s)
          http.delete(statement.object.to_s + '/fcr:tombstone')
        end
      end
    end

    # make sure solr is empty
    url = Kumquat::Application.kumquat_config[:solr_url].chomp('/') + '/' +
        Kumquat::Application.kumquat_config[:solr_core] +
        '/update?stream.body=<delete><query>*:*</query></delete>'
    http.get(url)
    Solr::Solr.client.commit
  end

end
