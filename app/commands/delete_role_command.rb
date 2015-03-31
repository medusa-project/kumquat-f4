class DeleteRoleCommand < Command

  def initialize(role)
    @role = role
  end

  def execute
    if @role.required
      raise "The role \"#{@role.name}\" is required by the system and cannot "\
      "be deleted."
    end
    @role.destroy!
  end

  def object
    @role
  end

  def required_permissions
    super + [Permission::ROLES_DELETE]
  end

end
