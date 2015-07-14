module Admin

  class UriPrefixesController < ControlPanelController

    def create
      @new_prefix = URIPrefix.new(sanitized_params)
      begin
        @new_prefix.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-Kumquat-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: @new_prefix }
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        keep_flash
        render 'create'
      else
        response.headers['X-Psap-Result'] = 'success'
        flash['success'] = "URI prefix \"#{@new_prefix.prefix}\" created."
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    def destroy
      @prefix = URIPrefix.find(params[:id])
      begin
        @prefix.destroy!
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "URI prefix \"#{@prefix.prefix}\" deleted."
      ensure
        redirect_to admin_uri_prefixes_url
      end
    end

    def index
      @prefixes = URIPrefix.order(:prefix)
      @new_prefix = URIPrefix.new
    end

    private

    def sanitized_params
      params.require(:uri_prefix).permit(:prefix, :uri)
    end

  end

end
