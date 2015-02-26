class CreateRoleCommand < Command

  def initialize(role_params, doing_user, remote_ip)
    @role_params = role_params
    @doing_user = doing_user
    @remote_ip = remote_ip
    @role = Role.new(role_params)
  end

  def execute
    begin
      raise "#{@doing_user.username} has insufficient privileges to "\
      "create roles." unless @doing_user.has_permission?('roles.create')
      @role.save!
    rescue ActiveRecord::RecordInvalid => e
      #Event.create(description: "Attempted to create role, but failed: "\
      #"#{@role.errors.full_messages[0]}",
      #             user: @doing_user, remote_ip: @remote_ip,
      #             event_level: EventLevel::DEBUG)
      #raise "Failed to create role: #{@role.errors.full_messages[0]}"
    rescue => e
      #Event.create(description: "Attempted to create role, but failed: "\
      #"#{e.message}",
      #             user: @doing_user, remote_ip: @remote_ip,
      #             event_level: EventLevel::ERROR)
      raise ValidationError, "Failed to create role: #{e.message}"
    else
      #Event.create(description: "Created role \"#{@role.name}\"",
      #             user: @doing_user, remote_ip: @remote_ip)
    end
  end

  def object
    @role
  end

end
