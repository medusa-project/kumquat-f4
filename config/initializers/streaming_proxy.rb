require 'rack/streaming_proxy'

Kumquat::Application.configure do
  config.streaming_proxy.logger             = Rails.logger                          # stdout by default
  config.streaming_proxy.log_verbosity      = Rails.env.production? ? :low : :high  # :low or :high, :low by default
  config.streaming_proxy.num_retries_on_5xx = 0                                     # 0 by default
  config.streaming_proxy.raise_on_5xx       = true                                  # false by default

  # Will be inserted at the end of the middleware stack by default.
  config.middleware.use Rack::StreamingProxy::Proxy do |request|

    # Return the full URI to redirect the request to, or nil/false if the
    # request should continue on down the middleware stack.
    if request.path.match(/\/items\/.*\/master/)
      parts = request.path.split('/')
      index = 0
      parts.each_with_index do |part, i|
        index = i + 1 if part == 'items'
      end
      web_id = parts[index]
      item = Repository::Item.find_by_web_id(web_id)
      item.master_bytestream.repository_url
    end
  end
end
