# frozen_string_literal: true

# AuditLog model for HIPAA-compliant audit trails
# This model is immutable - no updates or deletes allowed
class AuditLog < ApplicationRecord
  # Use string IDs (UUIDs)
  before_create :generate_uuid

  # Associations
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Enums
  AUDIT_ACTIONS = %w[create update delete restore].freeze

  # Validations
  validates :action, presence: true, inclusion: { in: AUDIT_ACTIONS }
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true

  # Prevent updates and deletes
  before_update :prevent_update
  before_destroy :prevent_destroy

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_auditable, ->(auditable) { where(auditable: auditable) }
  scope :creates, -> { where(action: 'create') }
  scope :updates, -> { where(action: 'update') }
  scope :deletes, -> { where(action: 'delete') }
  scope :restores, -> { where(action: 'restore') }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Class methods
  def self.log_create(auditable, user: nil, ip_address: nil, user_agent: nil, metadata: {})
    create!(
      user: user,
      action: 'create',
      auditable: auditable,
      change_data: auditable.attributes,
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_update(auditable, user: nil, ip_address: nil, user_agent: nil, metadata: {})
    return unless auditable.saved_changes.present?

    create!(
      user: user,
      action: 'update',
      auditable: auditable,
      change_data: {
        before: auditable.saved_changes.transform_values(&:first),
        after: auditable.saved_changes.transform_values(&:last)
      },
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_delete(auditable, user: nil, ip_address: nil, user_agent: nil, metadata: {})
    create!(
      user: user,
      action: 'delete',
      auditable_type: auditable.class.name,
      auditable_id: auditable.id,
      change_data: auditable.attributes,
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.log_restore(auditable, user: nil, ip_address: nil, user_agent: nil, metadata: {})
    create!(
      user: user,
      action: 'restore',
      auditable: auditable,
      change_data: auditable.attributes,
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  # Instance methods
  def changed_attributes
    return [] unless action == 'update' && change_data.is_a?(Hash)

    change_data.dig('before')&.keys || []
  end

  def attribute_changed?(attribute)
    changed_attributes.include?(attribute.to_s)
  end

  def old_value(attribute)
    return nil unless action == 'update'
    change_data.dig('before', attribute.to_s)
  end

  def new_value(attribute)
    return nil unless action == 'update'
    change_data.dig('after', attribute.to_s)
  end

  def performed_by
    user&.full_name || 'System'
  end

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def prevent_update
    raise ActiveRecord::ReadOnlyRecord, 'AuditLog records are immutable'
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, 'AuditLog records cannot be deleted'
  end
end
