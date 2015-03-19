class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :key

      t.timestamps null: true
    end
  end
end
