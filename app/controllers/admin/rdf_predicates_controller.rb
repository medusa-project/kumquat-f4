module Admin

  class RdfPredicatesController < ControlPanelController

    def create
      @new_predicate = RDFPredicate.new(sanitized_params)
      begin
        @new_predicate.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-Kumquat-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: @new_predicate }
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        keep_flash
        render 'create'
      else
        response.headers['X-Psap-Result'] = 'success'
        flash['success'] = "RDF predicate \"#{@new_predicate.label}\" created."
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    def destroy
      @predicate = RDFPredicate.find(params[:id])
      begin
        @predicate.destroy!
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "RDF predicate \"#{@predicate.label}\" deleted."
      ensure
        redirect_to admin_rdf_predicates_url
      end
    end

    ##
    # Responds to GET /admin/rdf-predicates and
    # GET /admin/collections/:key/rdf-predicates.
    #
    def index
      @new_predicate = RDFPredicate.new
      if params[:repository_collection_key]
        @collection = Repository::Collection.find_by_key(
            params[:repository_collection_key])
        @db_collection = @collection.db_counterpart

        @global_predicates = RDFPredicate.where(collection_id: nil).order(:uri)
        @collection_predicates = RDFPredicate.where(collection: @db_collection)

        render 'index_collection'
      else
        @predicates = RDFPredicate.where(collection_id: nil).order(:uri)
      end
    end

    private

    def sanitized_params
      params.require(:rdf_predicate).permit(:collection_id, :uri, :label)
    end

  end

end
