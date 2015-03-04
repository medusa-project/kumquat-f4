# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Roles
roles = {}
roles[:admin] = Role.create!(key: 'admin', name: 'Administrators')
roles[:cataloger] = Role.create!(key: 'cataloger', name: 'Catalogers')
roles[:everybody] = Role.create!(key: 'everybody', name: 'Everybody')

# Permissions
Permission.create!(key: 'collections.create',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'collections.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'collections.update',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'control_panel.access',
                   roles: [roles[:admin], roles[:cataloger]])
Permission.create!(key: 'roles.create',
                   roles: [roles[:admin]])
Permission.create!(key: 'roles.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'roles.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'settings.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.create',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.delete',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.update',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.update_self',
                   roles: [roles[:admin], roles[:everybody]])
Permission.create!(key: 'users.disable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.enable',
                   roles: [roles[:admin]])
Permission.create!(key: 'users.view',
                   roles: [roles[:admin], roles[:cataloger]])

if Rails.env.development?

  # Users
  users = {}
  users[:admin] = User.create!(
      username: 'admin',
      roles: [roles[:admin]])
  users[:cataloger] = User.create!(
      username: 'cataloger',
      roles: [roles[:cataloger]])
  users[:disabled] = User.create!(
      username: 'disabled',
      roles: [roles[:cataloger]])

end
