module Admin

  class MetadataProfilesController < ControlPanelController

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
