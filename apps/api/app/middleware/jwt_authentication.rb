# frozen_string_literal: true

# JWT Authentication Middleware
# Extracts and validates JWT tokens from the Authorization header
# Sets current_user in the request environment for controllers
#
# Usage in ApplicationController:
#   before_action :authenticate_user!
#   attr_reader :current_user
#
class JwtAuthentication
  def initialize(app)
    @app = app
  end

  def call(env)
    # Extract token from Authorization header
    token = extract_token(env)

    if token
      begin
        # Decode and validate token
        decoded = JsonWebTokenService.decode(token)

        # Find user and set in environment
        user = User.find_by(id: decoded[:user_id])

        if user && user.status_active?
          env['current_user'] = user
          env['current_user_id'] = user.id

          # Set request context for audit logging
          Thread.current[:current_user] = user
          Thread.current[:request_ip] = extract_ip(env)
          Thread.current[:user_agent] = env['HTTP_USER_AGENT']
        end
      rescue JWT::DecodeError => e
        # Invalid token - will be handled by controller
        env['jwt_error'] = e.message
      rescue ActiveRecord::RecordNotFound
        env['jwt_error'] = 'User not found'
      end
    end

    # Set request context even without auth for guest actions
    Thread.current[:request_ip] ||= extract_ip(env)
    Thread.current[:user_agent] ||= env['HTTP_USER_AGENT']

    @app.call(env)
  ensure
    # Clean up thread-local variables
    Thread.current[:current_user] = nil
    Thread.current[:request_ip] = nil
    Thread.current[:user_agent] = nil
  end

  private

  def extract_token(env)
    auth_header = env['HTTP_AUTHORIZATION']
    return nil unless auth_header

    # Support both "Bearer TOKEN" and "TOKEN" formats
    auth_header.sub(/^Bearer\s+/, '')
  end

  def extract_ip(env)
    # Check for forwarded IP first (behind proxy/load balancer)
    env['HTTP_X_FORWARDED_FOR']&.split(',')&.first&.strip ||
      env['HTTP_X_REAL_IP'] ||
      env['REMOTE_ADDR']
  end
end
