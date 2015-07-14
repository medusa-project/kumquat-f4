class DeleteUserCommand < Command

  def self.required_permissions
    super + [Permission::DELETE_USERS]
  end

  def initialize(user)
    @user = user
  end

  def execute
    @user.destroy!
  end

  def object
    @user
  end

end
