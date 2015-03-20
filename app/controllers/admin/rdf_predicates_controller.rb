module Admin

  class RdfPredicatesController < ControlPanelController

    def create
      begin
        # modifying the predicates of a collection
        if params[:predicate_labels]
          collection = Repository::Collection.find_by_key(
              params[:repository_collection_key])
          db_collection = collection.db_counterpart
          command = UpdateDBCollectionCommand.new(db_collection, params)
          executor.execute(command)
        else # modifying global predicates
          params[:predicates].each do |id, props|
            if id.to_s.length == 36 # new predicates get UUID ids from the form
              RDB::RDFPredicate.create!(uri: props[:uri], label: props[:label])
            else
              p = RDB::RDFPredicate.find(id)
              if props[:_destroy].to_i == 1
                p.destroy!
              elsif p and !props[:uri].blank?
                p.update!(uri: props[:uri], label: props[:label])
              end
            end
          end
        end
      rescue => e
        flash['error'] = e.message
      else
        flash['success'] = 'RDF predicates updated.'
      ensure
        redirect_to :back
      end
    end

    ##
    # Responds to GET /admin/rdf-predicates and
    # GET /admin/collections/:key/rdf-predicates.
    #
    def index
      if params[:repository_collection_key]
        @collection = Repository::Collection.find_by_key(
            params[:repository_collection_key])
        @db_collection = @collection.db_counterpart

        @global_predicates = RDB::RDFPredicate.where(collection_id: nil).order(:uri)
        @collection_predicates = RDB::RDFPredicate.where(collection: @db_collection)

        render 'index_collection'
      else
        @predicates = RDB::RDFPredicate.where(collection_id: nil).order(:uri)
      end
    end

  end

end
