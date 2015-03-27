module Admin

  class UsersController < ControlPanelController

    before_action :view_users_rbac, only: [:index, :show]

    ##
    # Responds to PATCH /users/:username/disable
    #
    def disable
      user = User.find_by_username params[:user_username]
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.enabled = false
        user.save!
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "User #{user.username} disabled."
      ensure
        redirect_to :back
      end
    end

    ##
    # Responds to PATCH /users/:username/enable
    #
    def enable
      user = User.find_by_username params[:user_username]
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.enabled = true
        user.save!
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

    def show
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
      @permissions = Permission.order(:key)
    end

    private

    def view_users_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::USERS_VIEW)
    end

  end

end