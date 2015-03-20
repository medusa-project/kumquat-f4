module Admin

  class RdfPredicatesController < ControlPanelController

    def create
      begin
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
      rescue ActiveRecord::RecordInvalid => e
        flash['error'] = e.message
      else
        flash['success'] = 'RDF predicates updated.'
      ensure
        redirect_to :back
      end
    end

    def index
      @predicates = RDB::RDFPredicate.where(collection_id: nil).order(:uri)
    end

  end

end
