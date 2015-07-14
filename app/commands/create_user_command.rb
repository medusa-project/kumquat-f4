class CreateUserCommand < Command

  def self.required_permissions
    super + [Permission::CREATE_USERS]
  end

  def initialize(user_params)
    @user_params = user_params
  end

  def execute
    @user = User.create!(@user_params)
  end

  def object
    @user
  end

end
