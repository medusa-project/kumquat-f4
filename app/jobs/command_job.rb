##
# Job that runs a Command.
#
class CommandJob < Job

  queue_as :default

  ##
  # @param args Hash with the following keys: :command (class),
  # :args (array; see documentation of super for restrictions),
  # :task_status_text
  #
  def perform(args)
    self.task.status_text = args[:task_status_text]
    self.task.save!
    command = args[:command].constantize.new(args[:args])
    command.task = self.task
    executor = CommandExecutor.new
    executor.execute(command)
  end

end
