##
# Encapsulates a permission in a role-based access control (RBAC) system.
# Permissions can be owned by zero or more roles and a role can have zero or
# more permissions.
#
# Permissions are basically just keys; it's up to the application to decide
# what permissions to define.
#
# To check whether a user or role has a given permission, use
# User.has_permission? or Role.has_permission?.
#
# To add a permission:
#
# 1) Assign it a constant and string value corresponding to its key
# 2) Create a Permission object with that key and save it
# 3) Add it to seed data
# 4) Add its key to the strings file(s) in config/locales
#
class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :key, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }

  CONTROL_PANEL_ACCESS = 'control_panel.access'
  COLLECTIONS_CREATE = 'collections.create'
  COLLECTIONS_DELETE = 'collections.delete'
  COLLECTIONS_UPDATE = 'collections.update'
  ROLES_CREATE = 'roles.create'
  ROLES_DELETE = 'roles.delete'
  ROLES_UPDATE = 'roles.update'
  SETTINGS_UPDATE = 'settings.update'
  USERS_CREATE = 'users.create'
  USERS_DELETE = 'users.delete'
  USERS_UPDATE = 'users.update'
  USERS_UPDATE_SELF = 'users.update_self'
  USERS_DISABLE = 'users.disable'
  USERS_ENABLE = 'users.enable'
  USERS_VIEW = 'users.view'

  def name
    I18n.t "permission_#{key.gsub('.', '_')}"
  end

  def readonly?
    !new_record?
  end

end
