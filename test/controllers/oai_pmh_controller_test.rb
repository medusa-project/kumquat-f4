require 'test_helper'

##
# Tests are roughly in order and labeled by section according to:
#
# http://www.openarchives.org/OAI/openarchivesprotocol.html
#
class OaiPmhControllerTest < ActionController::TestCase

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
=begin TODO: finish this
  test 'GetRecord requires certain arguments' do
    get :index, verb: 'GetRecord'
    assert_select 'error', 'Missing identifier argument.'
    assert_select 'error', 'Missing metadataPrefix argument.'
  end
=end

  # 4.2 Identify

  # 4.3 ListIdentifiers

  # 4.4 ListMetadataFormats

  # 4.5 ListRecords

  # 4.6 ListSets

  private

  def xsd_validate(params)
    get :index, params
    doc = Nokogiri::XML(response.body)
    xsd = Nokogiri::XML::Schema(
        File.read(File.join(Rails.root, 'test', 'controllers', 'OAI-PMH.xsd')))
    xsd.validate(doc).empty?
  end

end
