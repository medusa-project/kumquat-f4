class PublishCollectionJob < Job
  queue_as :default

  def perform(*args)
    self.task.status_text = "Publish collection \"#{args[0].title}\""
    self.task.save!
    command = PublishCollectionCommand.new(args[0])
    executor = CommandExecutor.new
    executor.execute(command)
  end
end
