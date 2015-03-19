class CreateTriples < ActiveRecord::Migration
  def change
    create_table :triples do |t|
      t.integer :collection_id
      t.string :predicate
      t.string :label

      t.timestamps null: false
    end
  end
end
