module Admin

  class FacetsController < ControlPanelController

    ##
    # XHR only
    #
    def create
      @facet = Facet.new(sanitized_params)
      begin
        @facet.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-Kumquat-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: @facet }
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        keep_flash
        render 'create'
      else
        response.headers['X-Psap-Result'] = 'success'
        flash['success'] = "Facet \"#{@facet.name}\" created."
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    def destroy
      facet = Facet.find(params[:id])
      begin
        facet.destroy!
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Facet deleted.'
      ensure
        redirect_to :back
      end
    end

    def index
      @facets = Facet.all.order(:index)
      @new_facet = Facet.new
    end

    ##
    # XHR only
    #
    def update
      facet = Facet.find(params[:id])
      begin
        facet.update!(sanitized_params)
      rescue ActiveRecord::RecordInvalid
        response.headers['X-Kumquat-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: facet }
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        keep_flash
        render 'update'
      else
        response.headers['X-Psap-Result'] = 'success'
        flash['success'] = "Facet \"#{facet.name}\" updated."
        keep_flash
        render 'update' # update.js.erb will reload the page
      end
    end

    private

    def sanitized_params
      params.require(:facet).permit(:index, :name, :solr_field)
    end

  end

end
