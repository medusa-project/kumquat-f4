class ExtractFullTextJob < Job
  queue_as :default

  def perform(*args)
    self.task.status_text = "Extract full text from item \"#{args[0].title}\""
    self.task.save!
    command = ExtractFullTextCommand.new(args[0])
    executor = CommandExecutor.new
    executor.execute(command)
  end
end
