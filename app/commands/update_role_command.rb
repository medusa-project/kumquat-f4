class UpdateRoleCommand < Command

  def initialize(role, role_params)
    @role = role
    @role_params = role_params
  end

  def execute
    @role.update!(@role_params)
  end

  def object
    @role
  end

  def required_permissions
    super + [Permission::ROLES_UPDATE]
  end

end
