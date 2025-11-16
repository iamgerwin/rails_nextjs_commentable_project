# frozen_string_literal: true

# Auditable - Module for automatically logging changes to models
# Replaces the deprecated ActiveRecord::Observer pattern with model callbacks
#
# Usage:
#   class User < ApplicationRecord
#     include Auditable
#   end
#
module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create_audit
    after_update :log_update_audit, if: :saved_changes?
    after_destroy :log_destroy_audit
  end

  private

  def log_create_audit
    return if is_a?(AuditLog) # Prevent infinite loop

    AuditLog.create!(
      user: current_audit_user,
      action: 'create',
      auditable: self,
      change_data: sanitize_audit_attributes(attributes),
      metadata: build_audit_metadata('create'),
      ip_address: current_audit_ip_address,
      user_agent: current_audit_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log create for #{self.class.name}: #{e.message}")
  end

  def log_update_audit
    return if is_a?(AuditLog)
    return unless saved_changes.present?

    AuditLog.create!(
      user: current_audit_user,
      action: 'update',
      auditable: self,
      change_data: {
        before: sanitize_audit_changes(saved_changes.transform_values(&:first)),
        after: sanitize_audit_changes(saved_changes.transform_values(&:last))
      },
      metadata: build_audit_metadata('update'),
      ip_address: current_audit_ip_address,
      user_agent: current_audit_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log update for #{self.class.name}: #{e.message}")
  end

  def log_destroy_audit
    return if is_a?(AuditLog)

    AuditLog.create!(
      user: current_audit_user,
      action: 'delete',
      auditable_type: self.class.name,
      auditable_id: id,
      change_data: sanitize_audit_attributes(attributes),
      metadata: build_audit_metadata('delete'),
      ip_address: current_audit_ip_address,
      user_agent: current_audit_user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Failed to log delete for #{self.class.name}: #{e.message}")
  end

  def current_audit_user
    # Try to get user from the record if it's a User
    return self if is_a?(User)

    # Try to get user from association
    try(:user)
  end

  def current_audit_ip_address
    # This will be set by middleware
    Thread.current[:request_ip]
  end

  def current_audit_user_agent
    # This will be set by middleware
    Thread.current[:user_agent]
  end

  def build_audit_metadata(action_type)
    {
      model: self.class.name,
      action: action_type,
      timestamp: Time.current.iso8601,
      source: 'model_callback'
    }
  end

  def sanitize_audit_attributes(attrs)
    # Remove sensitive fields from audit logs
    attrs.except('password_digest', 'password_reset_token', 'email_verification_token')
  end

  def sanitize_audit_changes(changes)
    changes.except('password_digest', 'password_reset_token', 'email_verification_token')
  end
end
