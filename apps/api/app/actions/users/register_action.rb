# frozen_string_literal: true

module Users
  # Action to register a new user
  # Handles user creation, email verification token generation, and optional email sending
  class RegisterAction < BaseAction
    attr_reader :email, :username, :password, :password_confirmation, :first_name, :last_name

    validates :email, :username, :password, :first_name, :last_name, presence: true
    validates :password, length: { minimum: 8 }
    validate :password_confirmation_matches

    def initialize(email:, username:, password:, password_confirmation:, first_name:, last_name:, **_options)
      @email = email
      @username = username
      @password = password
      @password_confirmation = password_confirmation
      @first_name = first_name
      @last_name = last_name
      super()
    end

    protected

    def perform
      user = User.new(
        email: email,
        username: username,
        password: password,
        password_confirmation: password_confirmation,
        first_name: first_name,
        last_name: last_name,
        role: 'user',
        status: 'active'
      )

      if user.save
        # Queue email verification (will implement with Sidekiq later)
        # SendEmailVerificationJob.perform_later(user.id)

        success(value: {
          user: user,
          tokens: JsonWebTokenService.generate_tokens(user)
        })
      else
        failure(errors: user.errors.full_messages)
      end
    end

    def should_audit?
      true
    end

    def log_audit_trail
      AuditLog.log_create(
        @value[:user],
        user: nil, # System action during registration
        metadata: { action: 'user_registration', source: 'api' }
      )
    end

    private

    def password_confirmation_matches
      return if password == password_confirmation

      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end
