# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Base controller for admin namespace
      # Ensures only admins and moderators can access admin endpoints
      class BaseController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :authorize_admin!

        private

        def authorize_admin!
          unless current_user&.can_moderate?
            render_forbidden('Admin or moderator access required')
          end
        end
      end
    end
  end
end
