class DisableUserCommand < Command

  def initialize(user)
    @user = user
  end

  def execute
    @user.enabled = false
    @user.save!
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::DISABLE_USERS]
  end

end
