class CreateUriPrefixes < ActiveRecord::Migration
  def change
    create_table :uri_prefixes do |t|
      t.string :uri
      t.string :prefix

      t.timestamps null: false
    end
  end
end
