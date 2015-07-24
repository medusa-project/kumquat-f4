class CreateFacets < ActiveRecord::Migration
  def change
    create_table :facets do |t|
      t.integer :index
      t.string :label
      t.string :solr_field

      t.timestamps null: false
    end
  end
end
