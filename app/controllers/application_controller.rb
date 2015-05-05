class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  attr_reader :executor

  before_action :setup
  after_action :flash_in_response_headers

  def setup
    @executor = CommandExecutor.new(current_user)
    @job_runner = JobRunner.new(current_user)
  end

  def admin_user
    unless current_user.is_admin?
      flash['error'] = 'Access denied.'
      store_location
      redirect_to root_url
    end
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end

  protected

  ##
  # Normally the flash is discarded after being added to the response headers
  # (see flash_in_response_headers). Calling this method will save it, enabling
  # it to work with redirects. (Notably, it works different than flash.keep.)
  #
  def keep_flash
    @keep_flash = true
  end

  ##
  # Sets headers to be used in streaming downloads. Typically these would be
  # augmented with:
  #
  #     Content-Disposition: attachment; filename="foo"
  #
  # and then self.response_body would be set to an Enumerable to start the
  # streaming.
  #
  # Streaming requires a web server capable of it (not WEBrick).
  #
  def set_streaming_headers
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')
  end

  private

  @keep_flash = false

  ##
  # Stores the flash message and type ('error' or 'success') in the response
  # headers, where they can be accessed by an ajax callback. Afterwards, the
  # "normal" flash is cleared, which prevents it from working with redirects.
  # To prevent this, a controller should call keep_flash before redirecting.
  #
  def flash_in_response_headers
    if request.xhr?
      response.headers['X-Kumquat-Message-Type'] = 'error' unless
          flash['error'].blank?
      response.headers['X-Kumquat-Message-Type'] = 'success' unless
          flash['success'].blank?
      response.headers['X-Kumquat-Message'] = flash['error'] unless
          flash['error'].blank?
      response.headers['X-Kumquat-Message'] = flash['success'] unless
          flash['success'].blank?
      flash.clear unless @keep_flash
    end
  end

end
