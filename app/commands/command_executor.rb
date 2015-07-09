class CommandExecutor

  def self.check_permissions(command, user)
    missing_permissions = command.class.required_permissions.reject do |p|
      user.can?(p)
    end
    if missing_permissions.any?
      list = missing_permissions.map do |p|
        perm = Permission.find_by_key(p)
        perm ? perm.name.downcase : p
      end
      raise "#{user.username} has insufficient privileges for the "\
      "following actions: #{list.join(', ')}"
    end
  end

  ##
  # @param doing_user [User]
  #
  def initialize(doing_user = nil)
    @doing_user = doing_user
  end

  ##
  # Executes a `Command`. To run a command in the background, see the
  # documentation for `JobRunner::run_later`.
  #
  # @param command [Command]
  # @raise [StandardError]
  #
  def execute(command)
    begin
      self.class.check_permissions(command, @doing_user) if @doing_user
      command.execute
    rescue *[ActiveRecord::RecordInvalid, ActiveMedusa::RecordInvalid] => e
      if command.object.respond_to?('errors')
        message = "#{command.class.to_s} failed: "\
        "#{command.object.errors.full_messages[0]}"
      else
        message = "#{command.class.to_s} failed: #{e.message}"
      end
      Rails.logger.debug(message)
      raise e
    rescue => e
      message = "#{command.class.to_s} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message
    else
      message = "#{command.class.to_s} succeeded"
      Rails.logger.info(message)
    end
  end

end
