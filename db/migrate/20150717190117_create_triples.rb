class CreateTriples < ActiveRecord::Migration
  def change
    create_table :triples do |t|
      t.string :predicate
      t.string :object
      t.string :label
      t.boolean :searchable, default: true
      t.boolean :facetable, default: false
      t.boolean :visible, default: true
      t.integer :index
      t.integer :metadata_profile_id

      t.timestamps null: false
    end
  end
end
