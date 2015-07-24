class AddDefaultColumnToMetadataProfiles < ActiveRecord::Migration
  def change
    add_column :metadata_profiles, :default, :boolean, default: false
  end
end
