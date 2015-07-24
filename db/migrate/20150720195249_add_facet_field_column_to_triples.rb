class AddFacetFieldColumnToTriples < ActiveRecord::Migration
  def change
    add_column :triples, :facet_field, :string
  end
end
