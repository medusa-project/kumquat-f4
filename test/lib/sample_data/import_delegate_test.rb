require 'test_helper'

class ImportDelegateTest < ActiveSupport::TestCase

  setup do
    @delegate = SampleData::ImportDelegate.new
  end

  test 'total_number_of_items should return the correct number of items' do
    assert_equal 10, @delegate.total_number_of_items
  end

  test 'collection_key_of_item_at_index should return the correct key' do
    assert_equal @delegate.class::COLLECTION_KEY,
                 @delegate.collection_key_of_item_at_index(3)
  end

  test 'full_text_of_item_at_index should return the full text' do
    assert @delegate.full_text_of_item_at_index(5).start_with?('Harold')
  end

  test 'import_id_of_item_at_index should return the correct import ID' do
    index = 0
    assert_equal "#{@delegate.class::COLLECTION_KEY}-#{index}",
                 @delegate.import_id_of_item_at_index(index)
  end

  test 'master_pathname_of_item_at_index should return the master pathname' do
    pathname = File.join(Rails.root, 'lib', 'sample_data', 'sample_collection',
                         '800379272_de0817d41a.tiff')
    assert_equal pathname, @delegate.master_pathname_of_item_at_index(0)
  end

  test 'media_type_of_item_at_index should return the correct media type' do
    assert_equal 'image/tiff', @delegate.media_type_of_item_at_index(0)
  end

  test 'metadata_of_collection_of_item_at_index should return some metadata' do
    graph = @delegate.metadata_of_collection_of_item_at_index(0)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'metadata_of_item_at_index should return some metadata' do
    graph = @delegate.metadata_of_item_at_index(0)
    assert graph.has_predicate?(RDF::URI('http://purl.org/dc/elements/1.1/title'))
  end

  test 'slug_of_collection_of_item_at_index should return the correct slug' do
    assert_equal @delegate.class::COLLECTION_KEY,
                 @delegate.slug_of_collection_of_item_at_index(7)
  end

end
