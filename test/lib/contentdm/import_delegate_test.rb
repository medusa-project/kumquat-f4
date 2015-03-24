require 'test_helper'

class ImportDelegateTest < ActiveSupport::TestCase

  setup do
    @source_path = File.join(File.dirname(__FILE__), 'collections')
    @delegate = Contentdm::ImportDelegate.new(@source_path)
  end

  test 'cdm_item_at_index should return the correct item' do
    assert_equal 1, @delegate.send(:cdm_item_at_index, 2).pointer
    assert_nil @delegate.send(:cdm_item_at_index, 3)
  end

  test 'total_number_of_items should return the correct number of items' do
    assert_equal 3, @delegate.total_number_of_items
  end

  test 'collections should return the correct list of collections' do
    collections = @delegate.send(:collections)
    assert_equal 2, collections.length
    assert_equal 'Test Collection 2', collections[1].name
  end

  test 'collection_key_of_item_at_index should return the correct key' do
    assert_equal 'test2', @delegate.collection_key_of_item_at_index(2)
  end

  test 'import_id_of_item_at_index should return the correct import ID' do
    index = 2
    item = @delegate.send(:cdm_item_at_index, index)
    assert_equal "cdm-#{item.collection.alias}-#{item.pointer}",
                 @delegate.import_id_of_item_at_index(index)
  end

  test 'parent_import_id_of_item_at_index should return the correct parent ID' do
    assert_nil @delegate.parent_import_id_of_item_at_index(0)
    # TODO: test an item that has a parent
  end

  test 'master_pathname_of_item_at_index should return the correct pathname' do
    assert_equal File.join(@source_path, 'test', 'image', '3.txt'),
                 @delegate.master_pathname_of_item_at_index(0)
  end

  test 'metadata_of_collection_of_item_at_index should return metadata' do
    graph = @delegate.metadata_of_collection_of_item_at_index(0)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'metadata_of_item_at_index should return metadata' do
    graph = @delegate.metadata_of_item_at_index(0)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'slug_of_collection_of_item_at_index should return a correct slug' do
    assert_equal 'test2', @delegate.slug_of_collection_of_item_at_index(2)
  end

  test 'slug_of_item_at_index should return a correct slug' do
    assert_equal '1', @delegate.slug_of_item_at_index(2)
  end

  test 'web_id_of_item_at_index should return a correct web ID' do
    assert_equal 'test2-1', @delegate.web_id_of_item_at_index(2)
  end

end
