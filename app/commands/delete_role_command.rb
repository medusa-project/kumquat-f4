class DeleteRoleCommand < Command

  def initialize(role, doing_user, remote_ip)
    @role = role
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
      "delete roles." unless @doing_user.has_permission?('roles.delete')
      @role.destroy!
    rescue => e
      #Event.create(description: "Attempted to delete role "\
      #"\"#{@role.name},\" but failed: #{e.message}",
      #             user: @doing_user, remote_ip: @remote_ip,
      #             event_level: EventLevel::ERROR)
      raise "Failed to delete role: #{e.message}"
    else
      #Event.create(description: "Deleted role \"#{@role.name}\"",
      #             user: @doing_user, remote_ip: @remote_ip)
    end
  end

  def object
    @role
  end

end
