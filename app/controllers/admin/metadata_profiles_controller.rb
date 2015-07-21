module Admin

  class MetadataProfilesController < ControlPanelController

    def create
      @profile = MetadataProfile.new(sanitized_params)
      begin
        @profile.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-Kumquat-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: @profile }
      rescue => e
        response.headers['X-Kumquat-Result'] = 'error'
        flash['error'] = "#{e}"
        keep_flash
        render 'create'
      else
        response.headers['X-Psap-Result'] = 'success'
        flash['success'] = "Metadata profile \"#{@profile.name}\" created."
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    def index
      @profiles = MetadataProfile.order(:name)
      @new_profile = MetadataProfile.new
    end

    def show
      @profile = MetadataProfile.find(params[:id])
    end

    private

    def sanitized_params
      params.require(:metadata_profile).permit(:name)
    end

  end

end
