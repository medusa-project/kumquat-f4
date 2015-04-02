class AddPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
    add_column :users, :enabled, :boolean, default: :true
  end
end
