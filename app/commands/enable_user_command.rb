class EnableUserCommand < Command

  def initialize(user)
    @user = user
  end

  def execute
    @user.enabled = true
    @user.save!
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::ENABLE_USERS]
  end

end
