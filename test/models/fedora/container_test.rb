require 'test_helper'

class ContainerTest < ActiveSupport::TestCase

  test 'initializer should work' do
    url = 'http://example.org/'
    container = Container.new(fedora_url: url)
    assert_equal(url, container.fedora_url)
  end

  # create

  test 'create should respect the container_url argument' do
    resource = Container.create(@root_container_url)
    assert resource.fedora_url.start_with?(@root_container_url)
    resource.delete
  end

  test 'create_container should respect the slug argument' do
    slug = 'dfgdgfsdfgsdfg'
    resource = Container.create(@root_container_url, slug)
    assert resource.fedora_url.end_with?(slug)
    resource.delete
  end

  # make_indexable

  test 'make_indexable should make a container indexable' do
    resource = Container.create(@root_container_url)
    resource.make_indexable
    response = @http.get(resource.fedora_url)
    assert response.body.include?('indexable:Indexable')
    resource.delete
  end

end
