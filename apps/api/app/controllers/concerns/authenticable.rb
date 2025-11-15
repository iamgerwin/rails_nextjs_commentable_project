# frozen_string_literal: true

# Authenticable concern for JWT authentication in controllers
# Provides helper methods for authentication and authorization
module Authenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user

    # Rescue from Pundit authorization errors
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  # Authenticate user from JWT token
  # Call this as a before_action in controllers that require authentication
  def authenticate_user!
    @current_user = request.env['current_user']

    return if @current_user

    error_message = request.env['jwt_error'] || 'Authentication required'
    render_unauthorized(error_message)
  end

  # Optional authentication - sets current_user if token is valid, but doesn't require it
  def authenticate_user
    @current_user = request.env['current_user']
  end

  # Check if user is authenticated
  def user_signed_in?
    current_user.present?
  end

  # Check if current user is an admin
  def admin_user?
    current_user&.role_admin?
  end

  # Check if current user is a moderator or admin
  def moderator_user?
    current_user&.can_moderate?
  end

  # Require admin access
  def require_admin!
    return if admin_user?

    render_forbidden('Admin access required')
  end

  # Require moderator access
  def require_moderator!
    return if moderator_user?

    render_forbidden('Moderator access required')
  end

  # Authorize action using Pundit
  def authorize_action(record, action = nil)
    authorize record, action
  rescue Pundit::NotAuthorizedError
    render_forbidden('You are not authorized to perform this action')
  end

  private

  def user_not_authorized(_exception)
    render_forbidden('You are not authorized to perform this action')
  end

  def render_unauthorized(message = 'Authentication required')
    render json: {
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: message
      }
    }, status: :unauthorized
  end

  def render_forbidden(message = 'Access forbidden')
    render json: {
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: message
      }
    }, status: :forbidden
  end
end
