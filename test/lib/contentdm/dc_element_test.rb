require 'test_helper'

class DCElementTest < ActiveSupport::TestCase

  setup do
    @element = Contentdm::DCElement.new(name: 'title', value: 'cats')
  end

  test 'namespace_prefix should return the correct prefix' do
    assert_equal 'dc', @element.namespace_prefix
  end

  test 'uri should return the correct URI' do
    assert_equal 'http://purl.org/dc/elements/1.1/title', @element.uri
  end

end
