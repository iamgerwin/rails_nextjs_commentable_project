# frozen_string_literal: true

module Api
  module V1
    # Base controller for API v1
    # All v1 controllers should inherit from this controller
    class BaseController < ApplicationController
      include Authenticable
      include Pundit::Authorization

      # API versioning is handled via namespace routing
      # This ensures all endpoints are prefixed with /api/v1
      # CSRF protection is not needed for API (using JWT tokens instead)

      # Standard error handling for API responses
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :render_bad_request
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      # Pagination settings
      PAGINATION_DEFAULTS = {
        page: 1,
        per_page: 25,
        max_per_page: 100
      }.freeze

      protected

      # Render success response with data
      def render_success(data, status: :ok, meta: {})
        render json: {
          success: true,
          data: data,
          meta: meta
        }, status: status
      end

      # Render error response
      def render_error(message, code: 'ERROR', status: :bad_request, details: {})
        render json: {
          success: false,
          error: {
            code: code,
            message: message,
            details: details
          }
        }, status: status
      end

      # Record not found (404)
      def render_not_found(exception)
        render_error(
          exception.message,
          code: 'NOT_FOUND',
          status: :not_found
        )
      end

      # Validation error (422)
      def render_unprocessable_entity(exception)
        render_error(
          'Validation failed',
          code: 'VALIDATION_ERROR',
          status: :unprocessable_entity,
          details: exception.record.errors.messages
        )
      end

      # Bad request (400)
      def render_bad_request(exception)
        render_error(
          exception.message,
          code: 'BAD_REQUEST',
          status: :bad_request
        )
      end

      # Forbidden (403)
      def render_forbidden(exception)
        render_error(
          'You are not authorized to perform this action',
          code: 'FORBIDDEN',
          status: :forbidden
        )
      end

      # Unauthorized (401)
      def render_unauthorized(message = 'Authentication required')
        render_error(
          message,
          code: 'UNAUTHORIZED',
          status: :unauthorized
        )
      end

      # Pagination helpers
      def pagination_params
        {
          page: params[:page]&.to_i || PAGINATION_DEFAULTS[:page],
          per_page: [
            params[:per_page]&.to_i || PAGINATION_DEFAULTS[:per_page],
            PAGINATION_DEFAULTS[:max_per_page]
          ].min
        }
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          has_next_page: collection.next_page.present?,
          has_previous_page: collection.prev_page.present?
        }
      end

      # Sorting helpers
      def sort_params
        {
          sort_by: params[:sort_by] || 'created_at',
          sort_order: params[:sort_order]&.downcase == 'asc' ? 'asc' : 'desc'
        }
      end
    end
  end
end
