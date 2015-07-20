class AddCollectionMetadataProfileRelationship < ActiveRecord::Migration
  def change
    add_column :collections, :metadata_profile_id, :integer
  end
end
