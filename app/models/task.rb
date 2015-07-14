##
# A representation of an task (typically but not necessarily a Job) for
# display to an end user.
#
# To use:
#     task = Task.create!(name: 'Do Something',
#                         status: Task::Status::RUNNING,
#                         status_text: 'Doing something')
#     # do stuff...
#
#     task.percent_complete = 0.3
#     task.save!
#
#     # do some more stuff...
#
#     task.status_text = 'Wrapping up'
#     task.percent_complete = 0.9
#     task.save!
#
#     # done
#     task.status = Task::Status::SUCCESS
#     task.save!
#
class Task < ActiveRecord::Base

  ##
  # An enum-like class.
  #
  class Status

    WAITING = 0
    RUNNING = 1
    PAUSED = 2
    SUCCEEDED = 3
    FAILED = 4

    ##
    # @param status One of the Status constants
    # @return Human-readable status
    #
    def self.to_s(status)
      case status
        when Status::WAITING
          'Waiting'
        when Status::RUNNING
          'Running'
        when Status::PAUSED
          'Paused'
        when Status::SUCCEEDED
          'Succeeded'
        when Status::FAILED
          'Failed'
      end
    end

  end

  after_initialize :init
  before_save :constrain_progress, :auto_complete

  def init
    self.status ||= Status::RUNNING
  end

  def status=(status)
    write_attribute(:status, status)
    if status == Status::SUCCEEDED
      self.percent_complete = 1
      self.completed_at = Time.now
    end
  end

  private

  def auto_complete
    if (1 - self.percent_complete).abs <= 0.0000001
      self.status = Status::SUCCEEDED
      self.completed_at = Time.now
    end
  end

  def constrain_progress
    self.percent_complete = self.percent_complete.abs
    self.percent_complete = self.percent_complete > 1 ? 1 : self.percent_complete
  end

end
