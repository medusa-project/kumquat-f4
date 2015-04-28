Backburner.configure do |config|
  config.beanstalk_url    = 'beanstalk://127.0.0.1'
  config.tube_namespace   = 'kumquat'
  config.on_error         = lambda { |e| }
  config.max_job_retries  = 0
  config.retry_delay      = 5
  config.default_priority = 65536
  config.respond_timeout  = 120
  config.default_worker   = Backburner::Workers::Simple
  config.logger           = Rails.logger
end
