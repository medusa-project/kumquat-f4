class UpdateRoleCommand < Command

  def initialize(role, role_params, doing_user, remote_ip)
    @role = role
    @role_params = role_params
    @doing_user = doing_user
    @remote_ip = remote_ip
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
      "update roles." unless @doing_user.has_permission?(Permission::ROLES_UPDATE)
      @role.update!(@role_params)
    rescue ActiveRecord::RecordInvalid => e
      #Event.create(description: "Attempted to update role "\
      #"\"#{@role.name},\" but failed: "\
      #"#{@role.errors.full_messages[0]}",
      #             user: @doing_user, remote_ip: @remote_ip,
      #             event_level: EventLevel::DEBUG)
      raise ValidationError, "Failed to update role \"#{@role.name}\": "\
      "#{@role.errors.full_messages[0]}"
    rescue => e
      #Event.create(description: "Attempted to update role "\
      #"\"#{@role.name},\" but failed: #{e.message}",
      #             user: @doing_user, remote_ip: @remote_ip,
      #             event_level: EventLevel::ERROR)
      raise "Failed to update role \"#{@role.name}\": #{e.message}"
    else
      #Event.create(description: "Updated role \"#{@role.name}\"",
      #             user: @doing_user, remote_ip: @remote_ip)
    end
  end

  def object
    @role
  end

end
