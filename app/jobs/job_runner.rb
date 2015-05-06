class JobRunner

  ##
  # @param doing_user User
  #
  def initialize(doing_user = nil)
    @doing_user = doing_user
  end

  ##
  # @param job Job class (not instance)
  # @param args Arguments to pass to the job
  # @raise RuntimeError
  #
  def run(job, *args)
    begin
      CommandExecutor.check_permissions(job) if @doing_user
      job.perform_now(*args)
    rescue ActiveRecord::RecordInvalid => e
      message = "#{job.to_s} failed: #{e.message}"
      Rails.logger.debug(message)
      raise message
    rescue => e
      message = "#{job.to_s} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message
    else
      message = "#{job.to_s} succeeded"
      Rails.logger.info(message)
    end
  end

  alias_method :run_now, :run

  ##
  # Runs a given job later. To run a Command later, do something like this:
  #
  #     args = {
  #        command: DoSomethingCommand,
  #        args: @item,
  #        task_status_text: "Starting to do something"
  #     }
  #     runner.run_later(CommandJob, args)
  #
  # @param job Job class (not instance)
  # @param args Arguments to pass to the job
  # @raise RuntimeError
  #
  def run_later(job, *args)
    begin
      CommandExecutor.check_permissions(job) if @doing_user
      # can't pass a Class to a Job
      args[0][:command] = args[0][:command].to_s if args.any? and args[0][:command]
      job.perform_later(*args)
    rescue => e
      message = "#{job} failed: #{e.message}"
      Rails.logger.warn(message)
      raise message
    end
  end

end
