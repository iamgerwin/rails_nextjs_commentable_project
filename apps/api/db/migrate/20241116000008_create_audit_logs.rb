# frozen_string_literal: true

# Create audit_logs table
# Audit logs track all changes for HIPAA compliance
# This table is immutable (no updates or deletes)
class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :string do |t|
      # User who performed the action (nullable for system actions)
      t.string :user_id

      # Action performed
      t.string :action, null: false # create, update, delete, restore

      # Polymorphic association (auditable: any tracked entity)
      t.string :auditable_type, null: false
      t.string :auditable_id, null: false

      # Changes made (JSON)
      t.json :changes, default: {}

      # Additional metadata (JSON)
      t.json :metadata, default: {}

      # Request context
      t.string :ip_address
      t.text :user_agent

      # Timestamp (only created_at, no updated_at for immutability)
      t.datetime :created_at, null: false
    end

    # Foreign keys (nullify on user delete to preserve audit trail)
    add_foreign_key :audit_logs, :users, on_delete: :nullify

    # Indexes
    add_index :audit_logs, :user_id
    add_index :audit_logs, [:auditable_type, :auditable_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
