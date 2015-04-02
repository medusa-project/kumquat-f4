class DeleteUserCommand < Command

  def initialize(user)
    @user = user
  end

  def execute
    @user.destroy!
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::DELETE_USERS]
  end

end
