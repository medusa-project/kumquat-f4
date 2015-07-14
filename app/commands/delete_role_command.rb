class DeleteRoleCommand < Command

  def self.required_permissions
    super + [Permission::ROLES_DELETE]
  end

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

end
