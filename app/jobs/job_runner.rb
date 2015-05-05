class JobRunner

  ##
  # @param doing_user User
  #
  def initialize(doing_user = nil)
    @doing_user = doing_user
  end

  ##
  # @param job Job
  # @param args Arguments to pass to the job
  # @raise RuntimeError
  #
  def run(job, *args)
    begin
      check_permissions(job) if @doing_user
      job.class.perform_now(*args)
    rescue ActiveRecord::RecordInvalid => e
      if job.object and job.object.respond_to?('errors')
        message = "#{job.class.to_s} failed: "\
        "#{job.object.errors.full_messages[0]}"
      else
        message = "#{job.class.to_s} failed: #{e.message}"
      end
      Rails.logger.debug(message)
      raise message
    rescue => e
      message = "#{job.class.to_s} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message
    else
      message = "#{job.class.to_s} succeeded"
      Rails.logger.info(message)
    end
  end

  alias_method :run_now, :run

  ##
  # @param job Job
  # @param args Arguments to pass to the job
  # @raise RuntimeError
  #
  def run_later(job, *args)
    begin
      check_permissions(job) if @doing_user
      job.class.perform_later(*args)
    rescue => e
      message = "#{job.class.to_s} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message
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
        perm ? perm.name.downcase : p
      end
      raise "#{@doing_user.username} has insufficient privileges for the "\
      "following actions: #{list.join(', ')}"
    end
  end

end
