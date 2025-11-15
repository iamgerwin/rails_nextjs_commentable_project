# frozen_string_literal: true

module Api
  module V1
    # Health check controller for API v1
    # Provides version information and system status
    class HealthController < BaseController
      # GET /api/v1/health
      def show
        render_success(
          {
            status: 'healthy',
            version: 'v1',
            timestamp: Time.current.iso8601,
            environment: Rails.env,
            database: database_status,
            redis: redis_status
          }
        )
      end

      private

      def database_status
        ActiveRecord::Base.connection.active? ? 'connected' : 'disconnected'
      rescue StandardError
        'error'
      end

      def redis_status
        Redis.current.ping == 'PONG' ? 'connected' : 'disconnected'
      rescue StandardError
        'not_configured'
      end
    end
  end
end
