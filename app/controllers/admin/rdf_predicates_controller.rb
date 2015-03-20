module Admin

  class RdfPredicatesController < ControlPanelController

    def create
      params[:predicates].each do |id, props|
        p = RDB::RDFPredicate.find(id)
        if p
          p.label = props[:label]
          p.save!
        end
      end
      flash[:success] = 'RDF predicates updated.'
      redirect_to :back
    end

    def index
      @predicates = RDB::RDFPredicate.where(collection_id: nil).order(:uri)
    end

  end

end
