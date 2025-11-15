# frozen_string_literal: true

# Authorization policy for Comment model
class CommentPolicy < ApplicationPolicy
  # Anyone can view active comments if they can view the parent entity
  def show?
    return true if record.status_active?
    owner? || moderator?
  end

  # Authenticated users can create comments if they can view the commentable
  def create?
    user.present? && user.status_active?
  end

  # Users can reply to comments if they can view the parent comment
  def reply?
    user.present? && user.status_active? && record.status_active?
  end

  # Only owner or moderator can update
  def update?
    owner? || moderator?
  end

  # Only owner or moderator can delete
  def destroy?
    owner? || moderator?
  end

  # Pundit scope for filtering comments
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.can_moderate?
        # Moderators and admins can see all comments
        scope.all
      elsif user
        # Authenticated users can see active comments and their own
        scope.where(status: 'active').or(scope.where(user_id: user.id))
      else
        # Guest users can only see active comments
        scope.where(status: 'active')
      end
    end
  end
end
