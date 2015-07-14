class EnableUserCommand < Command

  def self.required_permissions
    super + [Permission::ENABLE_USERS]
  end

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

end
