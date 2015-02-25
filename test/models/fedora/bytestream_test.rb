require 'test_helper'

class BytestreamTest < ActiveSupport::TestCase

  # create

  test 'create should respect the container_url argument' do
    resource = Bytestream.create(@root_container_url)
    assert resource.fedora_url.start_with?(@root_container_url)
    resource.delete
  end

  test 'create should respect the slug argument' do
    slug = 'sadfasfdasfd'
    resource = Bytestream.create(@root_container_url, slug)
    assert resource.fedora_url.end_with?(slug)
    resource.delete
  end

  test 'create should respect the pathname argument' do
    pathname = File.realpath(__FILE__)
    resource = Bytestream.create(@root_container_url, nil, pathname)
    expected = File.read(pathname)
    actual = @http.get(resource.fedora_url).body
    assert_equal expected, actual
    resource.delete
  end

  test 'create_binary should respect the external_resource_url argument' do
    skip # TODO: write this
  end

end
