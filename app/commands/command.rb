##
# Abstract command class in the command pattern, from which all commands
# should inherit. Pass a Command to a CommandExecutor to execute it.
#
class Command

  ##
  # Executes the command, checking all relevant preconditions and raising an
  # error if anything goes wrong. Raised error messages should be suitable for
  # public consumption.
  #
  # This method is not for public use.
  #
  def execute
    raise NotImplementedError, 'Command must override execute method'
  end

  ##
  # Returns the object, if any, on which the command will or did act. This
  # method exists to establish convention, but is optional. Some commands may
  # operate on <> 1 object, in which case they might want to define their own
  # getter(s) instead of this.
  #
  def object
    nil
  end

  ##
  # Returns an array of permissions required to execute the command.
  #
  def required_permissions
    []
  end

end
