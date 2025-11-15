# frozen_string_literal: true

# Create users table
# Users are the core entity for authentication and authorization
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :string do |t|
      # Authentication
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest, null: false

      # Profile information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :bio
      t.string :avatar

      # Authorization
      t.string :role, null: false, default: 'user'

      # Account status
      t.string :status, null: false, default: 'active'

      # Email verification
      t.boolean :email_verified, default: false, null: false
      t.string :email_verification_token
      t.datetime :email_verified_at

      # Password reset
      t.string :password_reset_token
      t.datetime :password_reset_sent_at

      # Tracking
      t.datetime :last_login_at
      t.string :last_login_ip
      t.integer :sign_in_count, default: 0

      # Timestamps
      t.timestamps

      # Soft delete
      t.datetime :deleted_at
    end

    # Indexes for performance and uniqueness
    add_index :users, :email, unique: true, where: 'deleted_at IS NULL'
    add_index :users, :username, unique: true, where: 'deleted_at IS NULL'
    add_index :users, :role
    add_index :users, :status
    add_index :users, :email_verification_token, unique: true
    add_index :users, :password_reset_token, unique: true
    add_index :users, :deleted_at
  end
end
