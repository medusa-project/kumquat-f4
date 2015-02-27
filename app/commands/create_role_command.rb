class CreateRoleCommand < Command

  def initialize(role_params)
    @role_params = role_params
    @role = Role.new(role_params)
  end

  def execute
    @role.save!
  end

  def object
    @role
  end

  def required_permissions
    super + [Permission::ROLES_CREATE]
  end

end
