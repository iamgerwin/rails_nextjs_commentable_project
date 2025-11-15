# frozen_string_literal: true

module Api
  module V1
    # Authentication controller for user registration, login, and token management
    # Handles JWT token generation and refresh
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:register, :login, :refresh]

      # POST /api/v1/auth/register
      # Register a new user
      def register
        result = Users::RegisterAction.call(
          email: params[:email],
          username: params[:username],
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          first_name: params[:first_name],
          last_name: params[:last_name]
        )

        if result.success?
          render_success(
            {
              user: UserSerializer.new(result.value[:user]).as_json,
              tokens: result.value[:tokens]
            },
            status: :created
          )
        else
          render_error(
            result.error_messages,
            code: 'REGISTRATION_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/auth/login
      # Authenticate user and return tokens
      def login
        result = Users::LoginAction.call(
          email: params[:email],
          password: params[:password],
          ip_address: request.remote_ip
        )

        if result.success?
          render_success(
            {
              user: UserSerializer.new(result.value[:user]).as_json,
              tokens: result.value[:tokens]
            }
          )
        else
          render_error(
            result.error_messages,
            code: 'LOGIN_FAILED',
            status: :unauthorized
          )
        end
      end

      # POST /api/v1/auth/refresh
      # Refresh access token using refresh token
      def refresh
        refresh_token = params[:refresh_token]

        if refresh_token.blank?
          return render_error('Refresh token is required', code: 'MISSING_REFRESH_TOKEN', status: :bad_request)
        end

        begin
          tokens = JsonWebTokenService.refresh_access_token(refresh_token)
          render_success({ tokens: tokens })
        rescue JWT::DecodeError => e
          render_error(e.message, code: 'INVALID_REFRESH_TOKEN', status: :unauthorized)
        end
      end

      # DELETE /api/v1/auth/logout
      # Logout user (client-side token removal)
      def logout
        # Since we're using stateless JWT, logout is handled client-side
        # Optionally, implement token blacklisting here
        render_success({ message: 'Successfully logged out' })
      end

      # POST /api/v1/auth/verify_email
      # Verify user email with token
      def verify_email
        token = params[:token]

        if token.blank?
          return render_error('Verification token is required', code: 'MISSING_TOKEN', status: :bad_request)
        end

        user = User.find_by(email_verification_token: token)

        unless user
          return render_error('Invalid verification token', code: 'INVALID_TOKEN', status: :not_found)
        end

        if user.email_verified?
          return render_error('Email already verified', code: 'ALREADY_VERIFIED', status: :unprocessable_entity)
        end

        user.verify_email!

        render_success({
          message: 'Email verified successfully',
          user: UserSerializer.new(user).as_json
        })
      end

      # POST /api/v1/auth/forgot_password
      # Send password reset email
      def forgot_password
        email = params[:email]

        if email.blank?
          return render_error('Email is required', code: 'MISSING_EMAIL', status: :bad_request)
        end

        user = User.find_by(email: email.downcase.strip)

        if user
          user.generate_password_reset_token!
          # Queue background job to send email
          # SendPasswordResetEmailJob.perform_later(user.id)
        end

        # Always return success to prevent email enumeration
        render_success({
          message: 'If the email exists, a password reset link has been sent'
        })
      end

      # POST /api/v1/auth/reset_password
      # Reset password with token
      def reset_password
        token = params[:token]
        password = params[:password]
        password_confirmation = params[:password_confirmation]

        if token.blank? || password.blank?
          return render_error('Token and password are required', code: 'MISSING_PARAMETERS', status: :bad_request)
        end

        user = User.find_by(password_reset_token: token)

        unless user
          return render_error('Invalid reset token', code: 'INVALID_TOKEN', status: :not_found)
        end

        unless user.password_reset_valid?
          return render_error('Reset token has expired', code: 'EXPIRED_TOKEN', status: :unprocessable_entity)
        end

        if password != password_confirmation
          return render_error("Password confirmation doesn't match", code: 'PASSWORD_MISMATCH', status: :unprocessable_entity)
        end

        if user.update(password: password, password_confirmation: password_confirmation)
          user.clear_password_reset_token!

          render_success({
            message: 'Password reset successfully',
            tokens: JsonWebTokenService.generate_tokens(user)
          })
        else
          render_error(user.errors.full_messages.join(', '), code: 'PASSWORD_UPDATE_FAILED', status: :unprocessable_entity)
        end
      end
    end
  end
end
