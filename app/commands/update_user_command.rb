class UpdateUserCommand < Command

  def initialize(user, user_params)
    @user = user
    @user_params = user_params
  end

  def execute
    @user.update!(@user_params)
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::UPDATE_USERS]
  end

end
