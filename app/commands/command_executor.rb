class CommandExecutor

  ##
  # @param doing_user User
  #
  def initialize(doing_user = nil)
    @doing_user = doing_user
  end

  ##
  # @param command Command
  # @raise RuntimeError
  #
  def execute(command)
    check_permissions(command) if @doing_user

    begin
      command.execute
    rescue ActiveRecord::RecordInvalid => e
      if command.object.respond_to?('errors')
        message = "#{command.class.to_s} failed: "\
        "#{command.object.errors.full_messages[0]}"
      else
        message = "#{command.class.to_s} failed: #{e.message}"
      end
      Rails.logger.debug(message)
      raise message
    rescue => e
      message = "#{command.class.to_s} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message # TODO: make this a ValidationError?
    else
      message = "#{command.class.to_s} succeeded"
      Rails.logger.info(message)
    end
  end

  private

  def check_permissions(command)
    missing_permissions = command.required_permissions.reject do |p|
      @doing_user.can?(p)
    end
    if missing_permissions.any?
      list = missing_permissions.map do |p|
        perm = Permission.find_by_key(p)
        return perm ? perm.name.downcase : p
      end
      raise SecurityError, "#{@doing_user.username} has insufficient "\
        "privileges for the following actions: #{list.join(', ')}"
    end
  end

end
