# frozen_string_literal: true

# Authorization policy for User model
class UserPolicy < ApplicationPolicy
  # Anyone can view user profiles (scope will filter appropriately)
  def index?
    true
  end

  # Anyone can view active user profiles
  def show?
    record.status_active? || owner? || moderator?
  end

  # Users can update their own profile, admins can update any
  def update?
    owner? || admin?
  end

  # Users can delete their own account, admins can delete any
  def destroy?
    owner? || admin?
  end

  # Pundit scope for filtering users
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.can_moderate?
        # Moderators and admins can see all users
        scope.all
      else
        # Regular users and guests can only see active users
        scope.where(status: 'active')
      end
    end
  end
end
