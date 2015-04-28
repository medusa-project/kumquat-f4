class UnpublishCollectionJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    collection = Repository::Collection.find(args[0])
    command = UnpublishCollectionCommand.new(collection)
    executor = CommandExecutor.new
    executor.execute(command)
  end
end
