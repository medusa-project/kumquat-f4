class RefactorTripleFacetsRelationship < ActiveRecord::Migration
  def up
    remove_column :triples, :facetable
    remove_column :triples, :facet_field
    add_column :triples, :facet_id, :integer
    add_column :triples, :facet_label, :string
    rename_column :facets, :label, :name
  end

  def down
    add_column :triples, :facetable, :boolean
    add_column :triples, :facet_field, :string
    remove_column :triples, :facet_id
    remove_column :triples, :facet_label
    rename_column :facets, :name, :label
  end

end
