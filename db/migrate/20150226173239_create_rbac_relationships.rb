class CreateRbacRelationships < ActiveRecord::Migration
  def change
    create_table "permissions_roles", id: false, force: true do |t|
      t.integer "permission_id"
      t.integer "role_id"
    end
    create_table "roles_users", id: false, force: true do |t|
      t.integer "user_id"
      t.integer "role_id"
    end
  end
end
