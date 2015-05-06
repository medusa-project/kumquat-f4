class CreateRoleCommand < Command

  def self.required_permissions
    super + [Permission::ROLES_CREATE]
  end

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

end
