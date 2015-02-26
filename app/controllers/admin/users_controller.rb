module Admin

  class UsersController < ControlPanelController

    before_action :view_users_rbac, only: [:index, :show]

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