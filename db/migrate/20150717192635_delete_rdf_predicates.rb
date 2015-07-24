class DeleteRdfPredicates < ActiveRecord::Migration
  def change
    drop_table :rdf_predicates
  end
end
