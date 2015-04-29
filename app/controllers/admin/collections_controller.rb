module Admin

  class CollectionsController < ControlPanelController

    before_action :create_rbac, only: [:new, :create]
    before_action :delete_rbac, only: :destroy
    before_action :update_rbac, only: [:edit, :update]

    def create
      command = CreateCollectionCommand.new(sanitized_repo_params)
      @collection = command.object
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
        render 'new'
      else
        flash['success'] = "Collection \"#{@collection.title}\" created."
        redirect_to admin_repository_collection_url(@collection)
      end
    end

    def destroy
      @collection = Repository::Collection.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @collection

      command = DeleteCollectionCommand.new(@collection)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
        redirect_to admin_repository_collection_url(@collection)
      else
        flash['success'] = "Collection \"#{@collection.title}\" deleted."
        redirect_to admin_repository_collections_url
      end
    end

    def edit
      @collection = Repository::Collection.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @collection
    end

    def index
      @start = params[:start] ? params[:start].to_i : 0
      @limit = Option::integer(Option::Key::RESULTS_PER_PAGE)
      # TODO: find a way to sort by title
      @collections = Repository::Collection.order(:kq_system_collection_key).
          start(@start).limit(@limit)
      @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
      @num_shown = [@limit, @collections.total_length].min
    end

    def new
      @collection = Repository::Collection.new
    end

    ##
    # Responds to PATCH /admin/collections/:key/publish
    #
    def publish
      @collection = Repository::Collection.find_by_key(
          params[:repository_collection_key])
      raise ActiveRecord::RecordNotFound unless @collection

      command = PublishCollectionCommand.new(@collection)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "Collection \"#{@collection.title}\" published."
      ensure
        redirect_to :back
      end
    end

    def show
      @collection = Repository::Collection.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @collection

      @theme_options_for_select = [[ 'None (Use Global)', nil ]] +
          DB::Theme.order(:name).map{ |t| [ t.name, t.id ] }
    end

    ##
    # Responds to PATCH /admin/collections/:key/unpublish
    #
    def unpublish
      @collection = Repository::Collection.find_by_key(
          params[:repository_collection_key])
      raise ActiveRecord::RecordNotFound unless @collection

      command = UnpublishCollectionCommand.new(@collection)
      begin
        executor.execute(command)
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "Collection \"#{@collection.title}\" unpublished."
      ensure
        redirect_to :back
      end
    end

    def update
      @collection = Repository::Collection.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @collection

      if params[:repository_collection]
        command = UpdateRepositoryCollectionCommand.new(@collection,
                                                        sanitized_repo_params)
      else
        command = UpdateDBCollectionCommand.new(@collection.db_counterpart,
                                                sanitized_db_params)
      end

      begin
        executor.execute(command)
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        render 'edit' unless request.xhr?
      else
        response.headers['X-Kumquat-Result'] = 'success'
        flash['success'] = "Collection \"#{@collection.title}\" updated."
        redirect_to admin_repository_collection_url(@collection) unless request.xhr?
      end

      render 'show' if request.xhr?
    end

    private

    def create_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::COLLECTIONS_CREATE)
    end

    def delete_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::COLLECTIONS_DELETE)
    end

    def sanitized_db_params
      params.require(:db_collection).permit(:id, :theme_id)
    end

    def sanitized_repo_params
      params.require(:repository_collection).permit(:description, :key,
                                                    :published, :title)
    end

    def update_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::COLLECTIONS_UPDATE)
    end

  end

end
