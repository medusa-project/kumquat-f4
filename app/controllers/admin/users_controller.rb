module Admin

  class UsersController < ControlPanelController

    before_action :view_users_rbac, only: [:index, :show]

    def create
      @user = User.new(sanitized_params)
      params[:user][:role_ids] ||= []
      params[:user][:role_ids].each { |id| @user.roles << Role.find(id) }
      begin
        @user.save!
      rescue => e
        flash['error'] = "#{e}"
        render 'new'
      else
        flash['success'] = "User #{@user.username} created."
        redirect_to admin_users_path
      end
    end

    def destroy
      user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.destroy!
      rescue => e
        flash['error'] = "#{e}"
        redirect_to admin_users_url
      else
        if user == current_user
          flash['success'] = 'Your account has been deleted.'
          sign_out
          redirect_to root_url
        else
          flash['success'] = "User #{user.username} deleted."
          redirect_to admin_users_url
        end
      end
    end

    ##
    # Responds to PATCH /users/:username/disable
    #
    def disable
      user = User.find_by_username params[:user_username]
      raise ActiveRecord::RecordNotFound unless user

      command = DisableUserCommand.new(user)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "User #{user.username} disabled."
      ensure
        redirect_to :back
      end
    end

    def edit
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
      @roles = Role.all.order(:name)
    end

    ##
    # Responds to PATCH /users/:username/enable
    #
    def enable
      user = User.find_by_username params[:user_username]
      raise ActiveRecord::RecordNotFound unless user

      command = EnableUserCommand.new(user)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "User #{user.username} enabled."
      ensure
        redirect_to :back
      end
    end

    def index
      q = "%#{params[:q]}%"
      @users = User.where('users.username LIKE ?', q).order('username') # TODO: paginate
    end

    def new
      @user = User.new
      @roles = Role.all.order(:name)
    end

    def show
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
      @permissions = Permission.order(:key)
    end

    def update
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user

      @user.roles.destroy_all
      params[:user][:role_ids] ||= []
      params[:user][:role_ids].each { |id| @user.roles << Role.find(id) }
      begin
        @user.save!
      rescue => e
        flash['error'] = "#{e}"
        render 'new'
      else
        flash['success'] = "User #{@user.username} updated."
        redirect_to admin_users_path
      end
    end

    private

    def sanitized_params
      params.require(:user).permit(:username, :email, :enabled, :password,
                                   :password_confirmation,
                                   :role_ids)
    end

    def view_users_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::USERS_VIEW)
    end

  end

end