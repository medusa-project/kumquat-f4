class SignOutCommand < Command

  def initialize(user)
    @user = user
  end

  def execute
    # noop
    # This command basically exists to have something to pass to
    # CommandExecutor which will carry out any necessary logging. It doesn't
    # sign out itself because it would need access to SessionsHelper.
  end

  def object
    @user
  end

end
