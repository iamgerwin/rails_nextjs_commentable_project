# frozen_string_literal: true

# User model for authentication and authorization
# Supports soft delete via paranoia gem
class User < ApplicationRecord
  include Auditable

  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Soft delete
  acts_as_paranoid

  # Secure password
  has_secure_password

  # Associations
  has_many :videos, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :reported_reports, class_name: 'Report', foreign_key: 'reporter_id', dependent: :destroy
  has_many :reviewed_reports, class_name: 'Report', foreign_key: 'reviewer_id', dependent: :nullify
  has_many :audit_logs, dependent: :nullify

  # Enums
  enum :role, { user: 'user', moderator: 'moderator', admin: 'admin' }, prefix: true
  enum :status, { active: 'active', inactive: 'inactive', suspended: 'suspended', deleted: 'deleted' }, prefix: true

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false, conditions: -> { where(deleted_at: nil) } }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false, conditions: -> { where(deleted_at: nil) } }
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\z/, message: 'only allows letters, numbers, and underscores' }
  validates :username, length: { minimum: 3, maximum: 30 }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  validates :role, inclusion: { in: roles.keys }
  validates :status, inclusion: { in: statuses.keys }

  # Callbacks
  before_validation :normalize_email
  before_validation :normalize_username
  before_save :generate_email_verification_token, if: :email_changed?

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :verified, -> { where(email_verified: true) }
  scope :unverified, -> { where(email_verified: false) }
  scope :admins, -> { where(role: 'admin') }
  scope :moderators, -> { where(role: 'moderator') }
  scope :regular_users, -> { where(role: 'user') }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def verify_email!
    update!(
      email_verified: true,
      email_verified_at: Time.current,
      email_verification_token: nil
    )
  end

  def generate_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64(32)
    self.password_reset_sent_at = Time.current
    save!
  end

  def password_reset_valid?
    password_reset_sent_at.present? && password_reset_sent_at > 2.hours.ago
  end

  def clear_password_reset_token!
    update!(
      password_reset_token: nil,
      password_reset_sent_at: nil
    )
  end

  def record_login!(ip_address: nil)
    update!(
      last_login_at: Time.current,
      last_login_ip: ip_address,
      sign_in_count: sign_in_count + 1
    )
  end

  def can_moderate?
    role_admin? || role_moderator?
  end

  def can_administrate?
    role_admin?
  end

  def suspend!
    update!(status: 'suspended')
  end

  def activate!
    update!(status: 'active')
  end

  def deactivate!
    update!(status: 'inactive')
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_username
    self.username = username.downcase.strip if username.present?
  end

  def generate_email_verification_token
    self.email_verification_token = SecureRandom.urlsafe_base64(32)
    self.email_verified = false
    self.email_verified_at = nil
  end
end
