# frozen_string_literal: true

# User serializer for API responses
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :full_name, :initials,
             :bio, :avatar, :role, :status, :email_verified, :created_at, :updated_at

  # Conditionally include sensitive fields only for the user themselves
  def email
    object.email if show_sensitive_data?
  end

  def email_verified
    object.email_verified if show_sensitive_data?
  end

  private

  def show_sensitive_data?
    # Show sensitive data if viewing own profile or if admin
    scope&.id == object.id || scope&.role_admin?
  end
end
