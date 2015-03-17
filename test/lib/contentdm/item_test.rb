require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  setup do
    @source_path = File.join(File.dirname(__FILE__), 'collections')
    @collection = Contentdm::Collection.with_alias('test', @source_path)
    @item = Contentdm::Item.at_index(@source_path, @collection, 0)
  end

  test 'at_index should return the correct item' do
    assert_equal 1, @item.pointer
    assert @item.elements.select{ |e| e.name == 'title' }.any?

    @item = Contentdm::Item.at_index(@source_path, @collection, 1)
    assert_equal 2, @item.pointer

    @collection = Contentdm::Collection.with_alias('test2', @source_path)
    @item = Contentdm::Item.at_index(@source_path, @collection, 0)
    assert_equal 1, @item.pointer
  end

end
