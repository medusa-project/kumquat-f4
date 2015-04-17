require 'test_helper'

##
# Tests are roughly in order and labeled by section according to:
#
# http://www.openarchives.org/OAI/openarchivesprotocol.html
#
# Test instances of Fedora and Solr must be running.
#
class OaiPmhControllerTest < ActionController::TestCase

  setup do
    seed_repository
  end

  # 2.4
  test 'identifier should be a non-HTTP URI' do
    # TODO: write this
  end

  # 2.5.1
  test 'repository should not support deleted records' do
    get :index, verb: 'Identify'
    assert_select 'Identify > deletedRecord', 'no'
  end

  # 3.1.1
  test 'verb argument is required' do
    get :index
    assert_select 'error', 'Missing verb argument.'
  end

  test 'verb argument must be legal' do
    get :index, verb: 'cats'
    assert_select 'error', 'Illegal verb argument.'
  end

  # 3.1.1.2
  test 'POST requests must have the correct content type' do
    # incorrect type
    request.headers['Content-Type'] = 'text/plain'
    post :index, verb: 'Identify'
    assert_select 'error', 'Content-Type of POST requests must be '\
    'application/x-www-form-urlencoded'

    # correct type
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    post :index, verb: 'Identify'
    assert_select 'Identify > deletedRecord', 'no'
  end

  # 3.1.2.1
  test 'response content type must be text/xml' do
    get :index, verb: 'Identify'
    assert response.headers['Content-Type'].start_with?('text/xml')
  end

  # 3.2
  test 'response content type must be UTF-8' do
    get :index, verb: 'Identify'
    assert response.headers['Content-Type'].downcase.include?('charset=utf-8')
  end

  # 3.2
  test 'all responses must validate against the OAI-PMH XML schema' do
    assert xsd_validate({})
    assert xsd_validate({ verb: 'GetRecord', metadataPrefix: 'oai_dc' })
    assert xsd_validate({ verb: 'Identify' })
    assert xsd_validate({ verb: 'ListIdentifiers', metadataPrefix: 'oai_dc' })
    assert xsd_validate({ verb: 'ListMetadataFormats', metadataPrefix: 'oai_dc' })
    assert xsd_validate({ verb: 'ListRecords', metadataPrefix: 'oai_dc' })
    assert xsd_validate({ verb: 'ListSets', metadataPrefix: 'oai_dc' })
  end

  # 3.3.1
  test 'Identify response should include the correct date granularity' do
    get :index, verb: 'Identify'
    assert_select 'Identify > granularity', 'YYYY-MM-DDThh:mm:ssZ'
  end

  # 4.1 GetRecord
  test 'GetRecord should return a record when correct arguments are passed' do
    identifier = "oai:localhost:item-0"
    get :index, verb: 'GetRecord', metadataPrefix: 'oai_dc',
        identifier: identifier
    assert_select 'GetRecord > record > header > identifier', identifier
  end

  test 'GetRecord should return errors when certain arguments are missing' do
    get :index, verb: 'GetRecord'
    assert_select 'error', 'Missing identifier argument.'
    assert_select 'error', 'Missing metadataPrefix argument.'
  end

  test 'GetRecord should return errors when arguments are invalid' do
    get :index, verb: 'GetRecord', metadataPrefix: 'cats'
    assert_select 'error', 'The metadata format identified by the '\
    'metadataPrefix argument is not supported by this item.'

    get :index, verb: 'GetRecord', identifier: 'cats'
    assert_select 'error', 'The value of the identifier argument is unknown '\
    'or illegal in this repository.'
  end

  # 4.2 Identify
  # TODO: finish this

  # 4.3 ListIdentifiers
  # TODO: finish this

  # 4.4 ListMetadataFormats
  # TODO: finish this

  # 4.5 ListRecords
  # TODO: finish this

  # 4.6 ListSets
  # TODO: finish this

  private

  def delete_all_nodes
    url = Kumquat::Application.kumquat_config[:fedora_url]
    urls_to_delete = []

    RDF::Reader.open(url) do |reader|
      reader.each_statement do |statement|
        if statement.predicate.to_s == 'http://www.w3.org/ns/ldp#contains'
          unless statement.object.to_s.include?('fedora:system')
            urls_to_delete << statement.object.to_s
          end
        end
      end
    end

    http = HTTPClient.new
    urls_to_delete.each do |url|
      http.delete(url)
      http.delete(url + '/fcr:tombstone')
    end
  end

  def seed_repository
    delete_all_nodes
    importer = Import::Importer.new(TestFixturesImportDelegate.new)
    importer.import
    sleep 4 # wait for solr to catch up
    Solr::Solr.client.commit
    sleep 2 # wait again for solr to catch up
  end

  def xsd_validate(params)
    get :index, params
    doc = Nokogiri::XML(response.body)
    xsd = Nokogiri::XML::Schema(
        File.read(File.join(Rails.root, 'test', 'controllers', 'OAI-PMH.xsd')))
    xsd.validate(doc).empty?
  end

end
