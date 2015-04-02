require 'test_helper'

class CollectionTest < ActiveSupport::TestCase

  setup do
    @source_path = File.join(File.dirname(__FILE__), 'collections')
    @collection = Contentdm::Collection.with_alias('test', @source_path)
  end

  test 'with_alias should return a correctly initialized collection' do
    assert_equal 'test', @collection.alias
    assert @collection.elements.
               select{ |e| e.value.include?('This is the colldesc file') }.any?

    @collection = Contentdm::Collection.with_alias('test2', @source_path)
    assert @collection.elements.select{ |e| e.value == 'Test Collection 2' }.any?
  end

  test 'name should return the collection\'s name' do
    assert_equal 'This is the colldesc file.', @collection.name
  end

  test 'num_items should return the correct number of items' do
    assert_equal 4, @collection.num_items
  end

end
