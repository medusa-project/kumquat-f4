class DisableUserCommand < Command

  def self.required_permissions
    super + [Permission::DISABLE_USERS]
  end

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

end
