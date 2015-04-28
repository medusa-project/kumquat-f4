class UnpublishCollectionJob < Job
  queue_as :default

  def perform(*args)
    self.task.status_text = "Unpublish collection \"#{args[0].title}\""
    self.task.save!
    command = UnpublishCollectionCommand.new(args[0])
    executor = CommandExecutor.new
    executor.execute(command)
  end
end
