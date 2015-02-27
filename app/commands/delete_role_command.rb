class DeleteRoleCommand < Command

  def initialize(role)
    @role = role
  end

  def execute
    @role.destroy!
  end

  def object
    @role
  end

  def required_permissions
    super + [Permission::ROLES_DELETE]
  end

end
