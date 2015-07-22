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

  ACCESS_CONTROL_PANEL = 'control_panel.access'
  COLLECTIONS_CREATE = 'collections.create'
  COLLECTIONS_DELETE = 'collections.delete'
  COLLECTIONS_UPDATE = 'collections.update'
  CREATE_USERS = 'users.create'
  DELETE_USERS = 'users.delete'
  DISABLE_USERS = 'users.disable'
  ENABLE_USERS = 'users.enable'
  PUBLISH_COLLECTIONS = 'collections.publish'
  REINDEX = 'reindex'
  ROLES_CREATE = 'roles.create'
  ROLES_DELETE = 'roles.delete'
  ROLES_UPDATE = 'roles.update'
  SETTINGS_UPDATE = 'settings.update'
  UNPUBLISH_COLLECTIONS = 'collections.unpublish'
  UPDATE_ITEMS = 'items.update'
  UPDATE_USERS = 'users.update'
  USERS_UPDATE_SELF = 'users.update_self'
  USERS_VIEW = 'users.view'

  def name
    I18n.t "permission_#{key.gsub('.', '_')}"
  end

  def readonly?
    !new_record?
  end

end
