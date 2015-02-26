class SessionsController < ApplicationController

  before_action :signed_out_user, only: [:new, :create]

  def new
  end

  def create
    username = params[:session] ? params[:session][:username] : ''
    password = params[:session] ? params[:session][:password] : ''

    command = SignInCommand.new(username, password, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to signin_url
    else
      sign_in command.object
      redirect_back_or root_url
    end
  end

  def destroy
    command = SignOutCommand.new(current_user, request.remote_ip)
    command.execute
    sign_out
    redirect_to root_url
  end

  private

  def signed_out_user
    if signed_in?
      redirect_to root_url
    end
  end

end
