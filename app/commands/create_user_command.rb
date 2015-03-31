class CreateUserCommand < Command

  def initialize(user_params)
    @user_params = user_params
  end

  def execute
    @user = User.create!(@user_params)
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::CREATE_USERS]
  end

end
