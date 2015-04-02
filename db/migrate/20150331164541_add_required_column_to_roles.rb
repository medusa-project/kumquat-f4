class AddRequiredColumnToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :required, :boolean, default: :false
  end
end
