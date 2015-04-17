##
# Import delegate that seeds F4 with test data.
#
class TestFixturesImportDelegate < Import::AbstractDelegate

  def root_container_url
    Kumquat::Application.kumquat_config[:fedora_url]
  end

  def total_number_of_items
    2
  end

  def collection_key_of_item_at_index(index)
    'test'
  end

  def import_id_of_item_at_index(index)
    "test-#{index}"
  end

  def metadata_of_collection_of_item_at_index(index)
    graph = RDF::Graph.new
    graph << RDF::Statement.new(
        RDF::URI(),
        RDF::URI('http://purl.org/dc/elements/1.1/title'),
        'Test Collection')
    graph
  end

  def metadata_of_item_at_index(index)
    graph = RDF::Graph.new
    graph << RDF::Statement.new(
        RDF::URI(),
        RDF::URI('http://purl.org/dc/elements/1.1/title'),
        'Test Item')
    graph
  end

  def web_id_of_item_at_index(index)
    "item-#{index}"
  end

end