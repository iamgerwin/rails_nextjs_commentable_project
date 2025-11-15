# frozen_string_literal: true

# JWT Service for encoding and decoding JSON Web Tokens
# Handles access tokens and refresh tokens with different expiration times
class JsonWebTokenService
  # Secret key for JWT encoding/decoding
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV['JWT_SECRET_KEY']

  # Token expiration times
  ACCESS_TOKEN_EXPIRATION = 1.hour.to_i
  REFRESH_TOKEN_EXPIRATION = 7.days.to_i

  class << self
    # Encode a payload into a JWT token
    # @param payload [Hash] Data to encode
    # @param exp [Integer] Expiration time in seconds (optional)
    # @return [String] Encoded JWT token
    def encode(payload, exp: ACCESS_TOKEN_EXPIRATION)
      payload[:exp] = exp.from_now.to_i
      payload[:iat] = Time.current.to_i
      JWT.encode(payload, SECRET_KEY, 'HS256')
    end

    # Decode a JWT token
    # @param token [String] JWT token to decode
    # @return [Hash] Decoded payload
    # @raise [JWT::DecodeError] If token is invalid or expired
    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature
      raise JWT::ExpiredSignature, 'Token has expired'
    rescue JWT::DecodeError => e
      raise JWT::DecodeError, "Invalid token: #{e.message}"
    end

    # Generate access and refresh tokens for a user
    # @param user [User] User to generate tokens for
    # @return [Hash] Hash containing access_token, refresh_token, and expires_in
    def generate_tokens(user)
      {
        access_token: encode({ user_id: user.id, type: 'access' }),
        refresh_token: encode({ user_id: user.id, type: 'refresh' }, exp: REFRESH_TOKEN_EXPIRATION),
        expires_in: ACCESS_TOKEN_EXPIRATION
      }
    end

    # Verify if a token is valid
    # @param token [String] Token to verify
    # @return [Boolean] True if valid, false otherwise
    def valid_token?(token)
      decode(token)
      true
    rescue JWT::DecodeError
      false
    end

    # Extract user from token
    # @param token [String] JWT token
    # @return [User, nil] User if found, nil otherwise
    def user_from_token(token)
      decoded = decode(token)
      User.find_by(id: decoded[:user_id])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end

    # Refresh an access token using a refresh token
    # @param refresh_token [String] Valid refresh token
    # @return [Hash] New access and refresh tokens
    # @raise [JWT::DecodeError] If refresh token is invalid
    def refresh_access_token(refresh_token)
      decoded = decode(refresh_token)

      raise JWT::DecodeError, 'Invalid token type' unless decoded[:type] == 'refresh'

      user = User.find(decoded[:user_id])
      generate_tokens(user)
    rescue ActiveRecord::RecordNotFound
      raise JWT::DecodeError, 'User not found'
    end

    # Validate token type
    # @param token [String] JWT token
    # @param expected_type [String] Expected token type ('access' or 'refresh')
    # @return [Boolean] True if type matches
    def valid_token_type?(token, expected_type)
      decoded = decode(token)
      decoded[:type] == expected_type
    rescue JWT::DecodeError
      false
    end
  end
end
