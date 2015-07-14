require 'test_helper'

class ImportDelegateTest < ActiveSupport::TestCase

  setup do
    @delegate = SampleData::ImportDelegate.new
  end

  test 'total_number_of_items should return the correct number of items' do
    assert_equal 16, @delegate.total_number_of_items
  end

  test 'collection_key_of_item_at_index should return the correct key' do
    assert_equal 'audio-sample', @delegate.collection_key_of_item_at_index(0)
    assert_equal 'doc-sample', @delegate.collection_key_of_item_at_index(2)
  end

  test 'full_text_of_item_at_index should return the full text' do
    assert @delegate.full_text_of_item_at_index(10).start_with?('Harold')
  end

  test 'import_id_of_item_at_index should return the correct import ID' do
    index = 0
    assert_equal "audio-sample-#{index}",
                 @delegate.import_id_of_item_at_index(index)
    index = 2
    assert_equal "doc-sample-#{index}",
                 @delegate.import_id_of_item_at_index(index)
  end

  test 'parent_import_id_of_item_at_index should return the correct parent import ID' do
    assert_equal @delegate.import_id_of_item_at_index(4),
                 @delegate.parent_import_id_of_item_at_index(5)
    assert_nil @delegate.parent_import_id_of_item_at_index(0)
  end

  test 'master_pathname_of_item_at_index should return the master pathname' do
    pathname = File.join(SampleData::ImportDelegate::SOURCE_PATH,
                         '800379272_de0817d41a.tiff')
    assert_equal pathname, @delegate.master_pathname_of_item_at_index(7)
  end

  test 'media_type_of_item_at_index should return the correct media type' do
    assert_equal 'image/tiff', @delegate.media_type_of_item_at_index(7)
  end

  test 'metadata_of_collection_of_item_at_index should return some metadata' do
    graph = @delegate.metadata_of_collection_of_item_at_index(7)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'metadata_of_item_at_index should return some metadata' do
    graph = @delegate.metadata_of_item_at_index(7)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'metadata_of_item_at_index should not return any blank objects' do
    graph = @delegate.metadata_of_item_at_index(10)
    graph.each_statement do |st|
      assert !st.object.to_s.blank?
    end
  end

  test 'slug_of_collection_of_item_at_index should return the correct slug' do
    assert_equal 'audio-sample', @delegate.slug_of_collection_of_item_at_index(0)
  end

end
