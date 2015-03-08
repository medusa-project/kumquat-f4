require 'test_helper'

class BaseTest < ActiveSupport::TestCase

  class TestModel < ActiveKumquat::Base
  end

  @@http = HTTPClient.new

  setup do
    @container_url = Kumquat::Application.kumquat_config[:fedora_url]
    response = @@http.post(@container_url)
    @container_url = response.header['Location'].first
    @model = TestModel.new(web_id: 'test',
                           container_url: @container_url,
                            requested_slug: 'test')
    @model.save
  end

  teardown do
    @@http.delete(@container_url)
  end

  # initialize

  test 'initialize should reject certain params' do
    model = TestModel.new(id: 'dogs', uuid: 'dogs')
    assert_nil model.id
    assert_nil model.uuid
  end

  # delete

  test 'delete should delete' do
    assert_raise HTTPClient::BadResponseError do
      @model.delete
      response = @@http.get(@model.fedora_url)
      assert_equal 410, response.status
      response = @@http.get("#{@model.fedora_url.chomp('/')}/fcr:tombstone")
      assert_equal 200, response.status
    end
  end

  test 'delete also_tombstone parameter should work' do
    assert_raise HTTPClient::BadResponseError do
      @model.delete(true)
      response = @@http.get(@model.fedora_url)
      assert_equal 404, response.status
      response = @@http.get("#{@model.fedora_url.chomp('/')}/fcr:tombstone")
      assert_equal 404, response.status
    end
  end

  test 'delete commit_immediately parameter should work' do
    skip # TODO: write this
  end

  # destroyed?

  test 'destroyed? should return the correct value' do
    assert !@model.destroyed?
    @model.delete
    assert @model.destroyed?
  end

  # persisted?

  test 'persisted? should return the correct value' do
    assert @model.persisted?
    model = TestModel.new
    assert !model.persisted?
  end

  # populate_from_graph

  test 'populate_from_graph should work properly' do
    skip # TODO: write this
  end

  # populate_into_graph

  test 'populate_into_graph should work properly' do
    skip # TODO: write this
  end

  # reload!

  test 'reload! should refresh the instance' do
    skip # TODO: write this
  end

  # save

  test 'save on a new instance should create it' do
    skip # TODO: write this
  end

  test 'save on an existing instance should update it' do
    skip # TODO: write this
  end

  test 'save commit_immediately parameter should work' do
    skip # TODO: write this
  end

  # to_param

  test 'to_param should return the web ID' do
    assert_equal @model.web_id, @model.to_param
  end

  # to_sparql_update

  test 'to_sparql_update should work properly' do
    skip # TODO: write this
  end

  # update

  test 'update should update the instance' do
    @model.update(web_id: 'dogs')
    assert_equal 'dogs', @model.web_id
  end

  # update!

  test 'update! should update the instance and save it' do
    @model.update!(web_id: 'dogs')
    assert_equal 'dogs', @model.web_id
    # TODO: this doesn't really test whether the instance has been saved
  end

end
