module Admin

  class ControlPanelController < ApplicationController

    layout 'admin/application'

    attr_reader :executor

    before_action :signed_in_user, :can_access_control_panel

    def setup
      super
      @executor = CommandExecutor.new(current_user)
    end

    private

    def can_access_control_panel
      unless current_user.has_permission?('control_panel.access')
        flash['error'] = 'Access denied.'
        redirect_to root_url
      end
    end

  end

end
