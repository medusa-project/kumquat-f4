class CreateRdfPredicates < ActiveRecord::Migration
  def change
    create_table :rdf_predicates do |t|
      t.integer :collection_id
      t.string :uri
      t.string :label

      t.timestamps null: false
    end
  end
end
