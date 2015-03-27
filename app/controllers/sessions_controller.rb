class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    auth_hash = request.env['omniauth.auth']
    if Rails.env.production?
      # TODO: write this
    else
      @user = User.find_by_email(auth_hash[:uid])
      if @user
        self.current_user = @user
        redirect_back_or root_url
      else
        flash[:error] = 'Sign-in failed.'
        redirect_to signin_url
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  ##
  # Responds to GET /signin
  #
  def new
    session[:login_return_referer] = request.env['HTTP_REFERER']
    if Rails.env.production?
      # TODO: write this
      #redirect_to(shibboleth_login_path(MedusaCollectionRegistry::Application.shibboleth_host))
    else
      redirect_to('/auth/developer')
    end
  end

end
