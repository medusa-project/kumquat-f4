module Admin

  class TasksController < ControlPanelController

    ##
    # Responds to GET /admin/tasks
    #
    def index
      @tasks = Task.order(created_at: :desc).limit(100)
    end

  end

end
