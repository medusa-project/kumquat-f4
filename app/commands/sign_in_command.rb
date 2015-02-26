class SignInFailure < RuntimeError

  def public_message
    @public_message
  end

  def public_message=(msg)
    @public_message = msg
  end

end

class SignInCommand < Command

  DEVELOPMENT_PASSWORD = 'password'

  def initialize(username, password, remote_ip)
    @username = username.chomp
    @password = password
    @remote_ip = remote_ip
    @user = nil
  end

  def execute
    begin
      @user = authenticate(@username, @password)
      if @user
      else
        public_message = 'Sign-in failed.'
        log_message = "Sign-in failed for #{@username}: invalid username "\
            "or password."

        ex = SignInFailure.new(log_message)
        ex.public_message = public_message
        raise ex
      end
    rescue SignInFailure => e
      #@user.events << Event.create(
      #    description: "#{e}", user: @user, remote_ip: @remote_ip,
      #    event_level: EventLevel::NOTICE)
      raise "#{e.public_message}"
    rescue => e
      #@user.events << Event.create(
      #    description: "#{e}", user: @user, remote_ip: @remote_ip,
      #    event_level: EventLevel::NOTICE)
      raise e
    else
      #@user.events << Event.create(
      #    description: "User #{@user.username} signed in",
      #    user: @user, remote_ip: @remote_ip)
    end
  end

  def object
    @user
  end

  private

  ##
  # @param username string
  # @param password string
  # @return User or nil depending on whether authentication was successful
  #
  def authenticate(username, password)
    user = User.find_by_username(username.downcase)
    if user
      if 1 == 2 # TODO: replace with e.g. Shibboleth auth result
        # noop
      elsif Rails.env.development? and @password == DEVELOPMENT_PASSWORD
        # noop
      else
        user = nil
      end
    end
    user
  end

end
