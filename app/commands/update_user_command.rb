class UpdateUserCommand < Command

  def initialize(user, user_params)
    @user = user
    @user_params = user_params
  end

  def execute
    if @user_params[:password]
      unless @user.authenticate(@user_params[:current_password])
        raise 'Current password is invalid.'
      end
    end

    @user.update!(@user_params.except(:current_password))
  end

  def object
    @user
  end

  def required_permissions
    super + [Permission::UPDATE_USERS]
  end

end
