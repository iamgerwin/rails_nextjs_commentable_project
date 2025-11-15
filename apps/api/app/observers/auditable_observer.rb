# frozen_string_literal: true

# AuditableObserver - Automatically logs changes to auditable models
# Implements the Observer pattern for HIPAA-compliant audit trails
#
# Usage:
#   Add to config/application.rb:
#     config.active_record.observers = :auditable_observer
#
class AuditableObserver < ActiveRecord::Observer
  observe :user, :video, :post, :comment, :reaction, :report

  # After create callback
  def after_create(record)
    return if record.is_a?(AuditLog) # Prevent infinite loop

    log_create(record)
  end

  # After update callback
  def after_update(record)
    return if record.is_a?(AuditLog)
    return unless record.saved_changes.present?

    log_update(record)
  end

  # After destroy callback (soft delete)
  def after_destroy(record)
    return if record.is_a?(AuditLog)

    log_delete(record)
  end

  private

  def log_create(record)
    AuditLog.create!(
      user: current_user_from_record(record),
      action: 'create',
      auditable: record,
      change_data: sanitize_attributes(record.attributes),
      metadata: build_metadata(record, 'create'),
      ip_address: current_ip_address,
      user_agent: current_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log create for #{record.class.name}: #{e.message}")
  end

  def log_update(record)
    AuditLog.create!(
      user: current_user_from_record(record),
      action: 'update',
      auditable: record,
      change_data: {
        before: sanitize_changes(record.saved_changes.transform_values(&:first)),
        after: sanitize_changes(record.saved_changes.transform_values(&:last))
      },
      metadata: build_metadata(record, 'update'),
      ip_address: current_ip_address,
      user_agent: current_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log update for #{record.class.name}: #{e.message}")
  end

  def log_delete(record)
    AuditLog.create!(
      user: current_user_from_record(record),
      action: 'delete',
      auditable_type: record.class.name,
      auditable_id: record.id,
      change_data: sanitize_attributes(record.attributes),
      metadata: build_metadata(record, 'delete'),
      ip_address: current_ip_address,
      user_agent: current_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log delete for #{record.class.name}: #{e.message}")
  end

  def current_user_from_record(record)
    # Try to get user from record if it's a User
    return record if record.is_a?(User)

    # Try to get user from association
    record.try(:user)
  end

  def current_ip_address
    # This will be set by middleware
    Thread.current[:request_ip]
  end

  def current_user_agent
    # This will be set by middleware
    Thread.current[:user_agent]
  end

  def build_metadata(record, action_type)
    {
      model: record.class.name,
      action: action_type,
      timestamp: Time.current.iso8601,
      source: 'observer'
    }
  end

  def sanitize_attributes(attributes)
    # Remove sensitive fields from audit logs
    attributes.except('password_digest', 'password_reset_token', 'email_verification_token')
  end

  def sanitize_changes(changes)
    changes.except('password_digest', 'password_reset_token', 'email_verification_token')
  end
end
