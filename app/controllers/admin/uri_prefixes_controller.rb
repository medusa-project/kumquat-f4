module Admin

  class UriPrefixesController < ControlPanelController

    def create
      begin
        params[:prefixes].each do |id, props|
          if id.to_s.length == 36 # new predicates get UUID ids from the form
            RDB::URIPrefix.create!(uri: props[:uri], prefix: props[:prefix])
          else
            p = RDB::URIPrefix.find(id)
            if props[:_destroy].to_i == 1
              p.destroy!
            elsif p and !props[:uri].blank?
              p.update!(uri: props[:uri], prefix: props[:prefix])
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        flash['error'] = e.message
      else
        flash['success'] = 'URI prefixes updated.'
      ensure
        redirect_to :back
      end
    end

    def index
      @prefixes = RDB::URIPrefix.order(:prefix)
    end

  end

end
