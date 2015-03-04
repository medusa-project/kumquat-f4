module Admin

  class CollectionsController < ControlPanelController

    before_action :create_rbac, only: [:new, :create]
    before_action :delete_rbac, only: :destroy
    before_action :update_rbac, only: [:edit, :update]

    def create
      command = CreateCollectionCommand.new(sanitized_params)
      @collection = command.object
      begin
        executor.execute(command)
      rescue => e
        flash[:error] = "#{e}"
        render 'new'
      else
        flash[:success] = "Collection \"#{@collection.title}\" created."
        redirect_to admin_collection_url(@collection)
      end
    end

    def destroy
      @collection = Collection.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @collection

      command = DeleteCollectionCommand.new(@collection)
      begin
        executor.execute(command)
      rescue => e
        flash[:error] = "#{e}"
        redirect_to admin_collection_url(@collection)
      else
        flash[:success] = "Collection \"#{@collection.title}\" deleted."
        redirect_to admin_collections_url
      end
    end

    def edit
      @collection = Collection.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @collection
    end

    def index
      solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])
      @limit = Kumquat::Application.kumquat_config[:results_per_page]
      @start = params[:start] ? params[:start].to_i : 0
      query = "kq_resource_type:#{Fedora::ResourceType::COLLECTION}"
      response = solr.get('select', params: {
                                      q: query,
                                      start: @start,
                                      sort: 'dc_title asc',
                                      rows: @limit })
      @num_results_shown = response['response']['docs'].length
      @collections = response['response']['docs'].map do |doc|
        collection = Collection.find(doc['id'])
        collection.solr_representation = doc.to_s
        collection
      end
      @collections.total_length = response['response']['numFound'].to_i
      @current_page = (@start / @limit.to_f).ceil + 1
    end

    def new
      @collection = Collection.new
    end

    def show
      @collection = Collection.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @collection
    end

    def update
      @collection = Collection.find_by_web_id(params[:web_id])
      raise ActiveRecord::RecordNotFound unless @collection

      command = UpdateCollectionCommand.new(@collection, sanitized_params)
      begin
        executor.execute(command)
      rescue => e
        @collections = Collection.all
        flash[:error] = "#{e}"
        render 'edit'
      else
        flash[:success] = "Collection \"#{@collection.name}\" updated."
        redirect_to admin_collection_url(@collection)
      end
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

    def sanitized_params
      params.require(:role).permit(:key, :name, permission_ids: [],
                                   user_ids: [])
    end

    def update_rbac
      redirect_to(admin_root_url) unless
          current_user.can?(Permission::COLLECTIONS_UPDATE)
    end

  end

end
