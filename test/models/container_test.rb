require 'test_helper'

class ContainerTest < ActiveSupport::TestCase

  test 'initializer should work' do
    url = 'http://example.org/'
    container = Container.new(fedora_url: url)
    assert_equal(url, container.fedora_url)
  end

end
