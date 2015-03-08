require 'test_helper'

class SparqlUpdateTest < ActiveSupport::TestCase

  setup do
    @update = ActiveKumquat::SparqlUpdate.new
  end

  test 'to_s should assemble a correct SPARQL update' do
    expected = 'PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX indexing: <http://fedora.info/definitions/v4/indexing#>
DELETE WHERE { <> <http://example.org/webID> ?o };
DELETE WHERE { ?s <indexing:hasIndexingTransformation> ?o };
DELETE WHERE { <> <rdf:type> "indexing:Indexable" };
INSERT {
  ?s dc:title "some-resource-title" .
  <> <http://example.org/webID> "badgers" .
  <> indexing:hasIndexingTransformation "kumquat" .
  <> rdf:type "indexing:Indexable" .
}
WHERE { }'
    @update.prefix('dc', 'http://purl.org/dc/elements/1.1/').
        prefix('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
        prefix('indexing', 'http://fedora.info/definitions/v4/indexing#').
        delete(nil, '<http://example.org/webID>', '?o').
        delete('?s', '<indexing:hasIndexingTransformation>', '?o').
        delete(nil, '<rdf:type>', '"indexing:Indexable"').
        insert('?s', 'dc:title', '"some-resource-title"').
        insert(nil, '<http://example.org/webID>', '"badgers"').
        insert(nil, 'indexing:hasIndexingTransformation', '"kumquat"').
        insert(nil, 'rdf:type', '"indexing:Indexable"')
    assert_equal expected, @update.to_s
  end

end