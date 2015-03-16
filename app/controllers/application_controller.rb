class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  before_action :setup

  def setup
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

end
