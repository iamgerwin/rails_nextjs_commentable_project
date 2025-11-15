# frozen_string_literal: true

# Explicitly require the middleware before use
require_relative '../../app/middleware/jwt_authentication'

# Add JWT Authentication middleware
Rails.application.config.middleware.use JwtAuthentication
