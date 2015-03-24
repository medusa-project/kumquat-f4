class AddDeletableAndSolrFieldColumnsToRdfPredicates < ActiveRecord::Migration
  def change
    add_column :rdf_predicates, :deletable, :boolean, default: true
    add_column :rdf_predicates, :solr_field, :string
  end
end
