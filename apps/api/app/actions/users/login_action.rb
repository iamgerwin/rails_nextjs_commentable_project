# frozen_string_literal: true

module Users
  # Action to authenticate and login a user
  # Handles credential verification, token generation, and login tracking
  class LoginAction < BaseAction
    attr_reader :email, :password, :ip_address

    validates :email, :password, presence: true

    def initialize(email:, password:, ip_address: nil, **_options)
      @email = email
      @password = password
      @ip_address = ip_address
      super()
    end

    protected

    def perform
      user = User.find_by(email: email.downcase.strip)

      unless user
        return failure(errors: ['Invalid email or password'])
      end

      unless user.authenticate(password)
        return failure(errors: ['Invalid email or password'])
      end

      unless user.status_active?
        return failure(errors: ["Account is #{user.status}. Please contact support."])
      end

      # Record login
      user.record_login!(ip_address: ip_address)

      success(value: {
        user: user,
        tokens: JsonWebTokenService.generate_tokens(user)
      })
    end

    def should_audit?
      success?
    end

    def log_audit_trail
      AuditLog.create!(
        user: @value[:user],
        action: 'update',
        auditable: @value[:user],
        change_data: { action: 'login' },
        metadata: { source: 'api', event: 'user_login' },
        ip_address: ip_address
      )
    end
  end
end
